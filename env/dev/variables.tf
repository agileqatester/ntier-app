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