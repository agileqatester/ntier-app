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

variable "my_ip" {
  type        = string
  description = "Your public IP with CIDR"
  default     = "85.65.171.123/32" # Narrowed to a specific IP
}

variable "public_key_path" {
  type        = string
  description = "Path to SSH public key"
  default     = "~/.ssh/id_rsa.pub"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for EC2 instance (Amazon Linux 2023)"
}

variable "instance_type" {
  type        = string
  default     = "t3.micro"
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
