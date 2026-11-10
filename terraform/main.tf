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
  default = "eu-central-1"
}

variable "security_group_id" {
  description = "Existing security group attached to your EC2 instance"
  type        = string
}

variable "ssh_cidr" {
  description = "Trusted IP range allowed to SSH, such as 203.0.113.10/32"
  type        = string
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
  description       = "SSH from trusted IP range"
  cidr_ipv4         = var.ssh_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}
