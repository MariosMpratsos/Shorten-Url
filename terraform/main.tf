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

# 1. HTTP Κανόνας
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
  id = "${var.security_group_id}_ingress_tcp_80_80_0.0.0.0/0"
}

# 2. HTTPS Κανόνας
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
  id = "${var.security_group_id}_ingress_tcp_443_443_0.0.0.0/0"
}

# 3. SSH Κανόνας
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = var.security_group_id
  description       = "SSH from trusted CIDR"
  cidr_ipv4         = var.ssh_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

import {
  to = aws_vpc_security_group_ingress_rule.ssh
  id = "${var.security_group_id}_ingress_tcp_22_22_${var.ssh_cidr}"
}
