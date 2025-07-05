## VPC
variable "aws_region" {}
variable "region" {}
variable "name_prefix" {}
variable "environment" {}
variable "vpc_cidr" {}
variable "vpc_cidr_blocks" {}
variable "public_subnet_cidrs" {}
variable "private_subnet_cidrs" {}
variable "azs" {}
## EKS
#variable "vpc_id" {}
variable "cluster_name" {}
variable "instance_types" {}
variable "ami_type" {}
variable "capacity_type" {}
variable "desired_capacity" {}
variable "min_capacity" {}
variable "max_capacity" {}

 ## Security
variable "k8s_namespace" {}
## secrets_manager
variable "db_username" {
  description = "RDS database username"
  type        = string
  default     = "postgres"
}

## ALB
variable "route53_zone_id" {
  description = "The Route 53 hosted zone ID for the ALB DNS record"
  type        = string
}

variable "subdomain_name" {
  description = "The subdomain name to create for the ALB (e.g. 'app' for app.example.com)"
  type        = string
}

variable "acm_certificate_arn" {
  description = "The ARN of the ACM certificate for HTTPS listeners"
  type        = string
}

variable my_ip {
  description = "My IP address in CIDR format (e.g., 1.2.3.4/32)"
  type        = string
}

# variable "jumpbox_security_group_id" {
#   description = "Security Group ID of the jumpbox"
#   type        = string
# }

variable "account_id" {}
variable "admin_temp_password" {}
variable "alb_arn" {}
variable "sns_topic_arn" {
  description = "SNS topic for CloudWatch alarms"
  type        = string
}
variable "resource_arn" {}
variable "rds_instance_id" {}
# variable "account_id" {}
# variable "account_id" {}
