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

# 1. Διαβάζουμε live το Security Group από το AWS για να δούμε τι κανόνες έχει ήδη
data "aws_security_group" "current" {
  id = var.security_group_id
}

# 2. HTTP: Δημιουργία ΜΟΝΟ αν δεν υπάρχει ήδη κανένας κανόνας για την port 80
resource "aws_vpc_security_group_ingress_rule" "http" {
  count             = length([for r in data.aws_security_group.current.inbound_rules : r if r.from_port == 80]) == 0 ? 1 : 0
  security_group_id = var.security_group_id
  description       = "HTTP"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

# 3. HTTPS: Δημιουργία ΜΟΝΟ αν δεν υπάρχει ήδη κανένας κανόνας για την port 443
resource "aws_vpc_security_group_ingress_rule" "https" {
  count             = length([for r in data.aws_security_group.current.inbound_rules : r if r.from_port == 443]) == 0 ? 1 : 0
  security_group_id = var.security_group_id
  description       = "HTTPS"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

# 4. SSH: Δημιουργία ΜΟΝΟ αν δεν υπάρχει ήδη κανένας κανόνας για την port 22
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  count             = length([for r in data.aws_security_group.current.inbound_rules : r if r.from_port == 22]) == 0 ? 1 : 0
  security_group_id = var.security_group_id
  description       = "SSH from trusted CIDR"
  cidr_ipv4         = var.ssh_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}
