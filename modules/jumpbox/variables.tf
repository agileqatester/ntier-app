variable "name_prefix" {
  type        = string
  description = "Prefix for resource naming"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "public_subnet_id" {
  type        = string
  description = "Public subnet ID"
}

variable "public_key_path" {
  type        = string
  description = "Path to SSH public key"
  default     = "~/.ssh/id_rsa.pub"
}

variable "ami_id" {
  description = "Optional override for AMI ID. If not set, a suitable Amazon Linux 2023 AMI will be used based on instance_type."
  type        = string
  default     = ""
}

variable "instance_type" {
  type        = string
  default     = "t4g.micro" # Default is Graviton (arm64)
  description = "EC2 instance type"
}

variable "rds_secret_arn" {
  type        = string
  description = "ARN of the secret storing RDS credentials"
}

variable "rds_host" {
  type        = string
  description = "RDS endpoint hostname"
}

variable "db_name" {
  type        = string
  default     = "products"
  description = "Initial database name to create"
}
variable my_ip {
  description = "My IP address in CIDR format (e.g., 1.2.3.4/32)"
  type        = string
}

# variable "jumpbox_security_group_id" {
#   description = "Security group ID of the jumpbox host"
#   type        = string
# }
variable "aws_region" {
  description = "AWS region to configure AWS CLI and SDKs"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "rds_security_group_id" {
  description = "RDS SG to allow access from jumpbox"
  type        = string
}