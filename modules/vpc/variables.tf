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



variable "enable_ipv6" {
  description = "Whether to enable IPv6 for the VPC (module does not support IPv6); keep false to avoid accidental IPv6 creation"
  type        = bool
  default     = false
}

// Ensure lists align: public & private subnet lists must match azs length and be non-empty
variable "_list_alignment_validation" {
  description = "internal placeholder to document list alignment; not used directly"
  type        = any
  default     = null
}

// Cross-variable validation: enforced on azs because validations must reference the variable being validated
variable "azs" {
  description = "List of availability zones"
  type        = list(string)

  validation {
    condition     = length(var.azs) > 0 && length(var.public_subnet_cidrs) == length(var.azs) && length(var.private_subnet_cidrs) == length(var.azs)
    error_message = "public_subnet_cidrs, private_subnet_cidrs and azs must be non-empty lists of equal length"
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

variable "nat_mode" {
  description = "NAT mode to use for private subnets: \"gateway\" (AWS NAT Gateway) or \"instance\" (NAT EC2 instance)."
  type        = string
  default     = "gateway"

  validation {
    condition     = contains(["gateway", "instance"], var.nat_mode)
    error_message = "nat_mode must be either \"gateway\" or \"instance\""
  }
}

variable "nat_instance_ami" {
  description = "Optional AMI ID to use for NAT instance. If empty, a default Amazon Linux 2023 x86_64 AMI will be used."
  type        = string
  default     = ""
}
