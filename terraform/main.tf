terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "name" {
  type    = string
  default = "shorten-url"
}

variable "domain" {
  type    = string
  default = "shorten.bratsos.online"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "app_ports" {
  description = "Public ports. 80/443 for nginx; the app containers stay on localhost."
  type        = list(number)
  default     = [80, 443]
}

variable "compose_version" {
  type    = string
  default = "v2.29.7"
}

provider "aws" {
  region = var.region
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

# ---------- IAM: lets the pipeline reach the server through SSM (no SSH, no port 22) ----------

resource "aws_iam_role" "ssm" {
  name = "${var.name}-ssm"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  name = "${var.name}-ssm"
  role = aws_iam_role.ssm.name
}

# ---------- Network ----------

resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "HTTP/HTTPS in, everything out"

  dynamic "ingress" {
    for_each = var.app_ports
    content {
      description = "Port ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------- Instance ----------

resource "aws_instance" "this" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.ssm.name
  vpc_security_group_ids = [aws_security_group.this.id]

  # Runs once on first boot. Log: /var/log/user-data.log
  user_data                   = <<-EOT
    #!/bin/bash
    set -euxo pipefail
    exec > >(tee /var/log/user-data.log) 2>&1

    # Base packages
    dnf update -y
    dnf install -y docker git jq unzip nginx python3 augeas-libs

    # SSM agent (already on Amazon Linux 2023, make sure it runs)
    systemctl enable --now amazon-ssm-agent

    # Docker
    systemctl enable --now docker
    usermod -aG docker ec2-user

    # Docker Compose plugin
    mkdir -p /usr/local/lib/docker/cli-plugins
    curl -fsSL "https://github.com/docker/compose/releases/download/${var.compose_version}/docker-compose-linux-x86_64" \
      -o /usr/local/lib/docker/cli-plugins/docker-compose
    chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

    # App directory used by the pipeline
    mkdir -p /opt/app
    chmod 755 /opt/app

    # Small swap file: a t3.micro has only 1 GB RAM
    if [ ! -f /swapfile ]; then
      dd if=/dev/zero of=/swapfile bs=1M count=1024
      chmod 600 /swapfile
      mkswap /swapfile
      swapon /swapfile
      echo '/swapfile swap swap defaults 0 0' >> /etc/fstab
    fi

    # Nginx reverse proxy: /api/ -> backend (prefix stripped), everything else -> frontend
    cat > /etc/nginx/conf.d/app.conf <<'NGINX'
    server {
        listen 80;
        server_name ${var.domain};
        client_max_body_size 5m;

        location /api/ {
            proxy_pass http://127.0.0.1:5000/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location / {
            proxy_pass http://127.0.0.1:3000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
    NGINX
    nginx -t
    systemctl enable --now nginx

    # Certbot (Let's Encrypt) in a venv; the pipeline requests the certificate
    # once the DNS record points at this server
    python3 -m venv /opt/certbot
    /opt/certbot/bin/pip install --upgrade pip
    /opt/certbot/bin/pip install certbot certbot-nginx
    ln -sf /opt/certbot/bin/certbot /usr/bin/certbot

    cat > /etc/systemd/system/certbot-renew.service <<'UNIT'
    [Unit]
    Description=Certbot renew

    [Service]
    Type=oneshot
    ExecStart=/usr/bin/certbot renew -q --deploy-hook "systemctl reload nginx"
    UNIT

    cat > /etc/systemd/system/certbot-renew.timer <<'UNIT'
    [Unit]
    Description=Daily certbot renew

    [Timer]
    OnCalendar=daily
    RandomizedDelaySec=3600
    Persistent=true

    [Install]
    WantedBy=timers.target
    UNIT

    systemctl daemon-reload
    systemctl enable --now certbot-renew.timer

    # Marker: everything above finished
    touch /opt/app/.bootstrap-done
  EOT
  user_data_replace_on_change = true

  metadata_options {
    http_tokens = "required" # IMDSv2 only
  }

  root_block_device {
    volume_size = 20
    encrypted   = true
  }

  tags = {
    Name = var.name
  }
}

# Stable public IP: point the DNS A record of the domain here
resource "aws_eip" "this" {
  instance = aws_instance.this.id
  domain   = "vpc"
}

# ---------- Outputs ----------

output "instance_id" {
  value = aws_instance.this.id
}

output "public_ip" {
  value       = aws_eip.this.public_ip
  description = "Create an A record for the domain pointing to this IP"
}

output "dns_record" {
  value = "A  ${var.domain}  ->  ${aws_eip.this.public_ip}"
}

output "connect_command" {
  value = "aws ssm start-session --target ${aws_instance.this.id}"
}
