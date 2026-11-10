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
  default = "eu-north-1" # 1. ΔΙΟΡΘΩΣΗ: Αλλαγή από eu-central-1 σε eu-north-1
}

variable "security_group_id" {
  description = "Existing security group attached to your EC2 instance"
  type        = string
  default     = "sg-0420e2c843ddc2108" # 2. ΔΙΟΡΘΩΣΗ: Το ID από το launch-wizard-2 του screenshot σας

  validation {
    condition     = can(regex("^sg-[0-9a-fA-F]+$", var.security_group_id))
    error_message = "security_group_id must be a valid AWS security group id like sg-0123456789abcdef0."
  }
}

variable "ssh_cidr" {
  description = "Trusted CIDR allowed to SSH into the existing instance."
  type        = string
  default     = "0.0.0.0/0" # 3. ΔΙΟΡΘΩΣΗ: Default επιλογή για να μην κολλάει το apply (μπορείτε να βάλετε την IP σας, π.χ. "X.X.X.X/32")

  validation {
    condition     = can(cidrhost(var.ssh_cidr, 0))
    error_message = "ssh_cidr must be a valid CIDR range."
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = var.security_group_id
  description       = "HTTP"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = var.security_group_id
  description       = "HTTPS"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = var.security_group_id
  description       = "SSH from trusted CIDR"
  cidr_ipv4         = var.ssh_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}
