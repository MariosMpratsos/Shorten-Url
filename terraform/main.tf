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
  # Change this to your public IP (e.g., "203.0.113.50/32") if accessing from the internet, 
  # or keep "0.0.0.0/0" if you want to allow SSH from anywhere.
  default = "0.0.0.0/0"
}

provider "aws" {
  region = var.aws_region
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
}

import {
  to = aws_vpc_security_group_ingress_rule.ssh
  id = "sgr-02167835db3fe1590"
}
