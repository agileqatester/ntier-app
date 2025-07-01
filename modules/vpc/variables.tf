variable "name_prefix" {
  description = "Prefix for naming AWS resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid CIDR block"
  }
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDRs"
  type        = list(string)
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)

  validation {
    condition     = length(var.azs) > 0
    error_message = "At least one AZ must be provided"
  }
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_cidr_blocks" {
  description = "List of CIDRs allowed for SG ingress"
  type        = list(string)
}
