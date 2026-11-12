terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "security_group_id" {
  type    = string
  default = "sg-0420e2c843ddc2108"
}

variable "ssh_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

provider "aws" {
  region = var.aws_region
}

# Finds the Default VPC in your AWS account
data "aws_vpc" "default" {
  default = true
}

# Private subnet: no public IPs assigned on launch
resource "aws_subnet" "main" {
  vpc_id                  = data.aws_vpc.default.id
  cidr_block              = "172.31.96.0/20"
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "main-terraform-private-subnet"
  }

  # map_public_ip_on_launch and tags are NOT ignored, so an already
  # existing subnet gets switched to private on apply.
  lifecycle {
    ignore_changes = [
      cidr_block,
      availability_zone,
    ]
  }
}

# Route table with only the implicit "local" route (no 0.0.0.0/0 to the
# internet gateway), which is what makes the subnet private.
resource "aws_route_table" "private" {
  vpc_id = data.aws_vpc.default.id

  tags = {
    Name = "main-terraform-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.private.id
}

# 1. HTTP Rule
resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = var.security_group_id
  description       = "HTTP"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

import {
  to = aws_vpc_security_group_ingress_rule.http
  id = "sgr-0e69b3eecbaf8345a"
}

# 2. HTTPS Rule
resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = var.security_group_id
  description       = "HTTPS"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

import {
  to = aws_vpc_security_group_ingress_rule.https
  id = "sgr-0c0532bd88ebd285a"
}

# 3. SSH Rule
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = var.security_group_id
  description       = "SSH from trusted CIDR"
  cidr_ipv4         = var.ssh_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22

  lifecycle {
    ignore_changes = [
      cidr_ipv4,
      description,
    ]
  }
}

import {
  to = aws_vpc_security_group_ingress_rule.ssh
  id = "sgr-02167835db3fe1590"
}

output "created_subnet_id" {
  value = aws_subnet.main.id
}
