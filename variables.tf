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

variable "db_name" {
  description = "RDS database name"
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

variable "public_key_path" {
  description = "Path to the SSH public key file for jumpbox (absolute path). Can be empty to skip importing."
  type        = string
  default     = ""
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
variable "rds_instance_id" {
  type    = string
  default = ""
}
variable "nat_mode" {
  description = "NAT mode to use for VPC module (gateway|instance)"
  type        = string
  default     = "gateway"
}

variable "log_retention_days" {
  type    = number
  default = 7
}

# Module toggles
variable "enable_rds" {
  description = "Enable RDS module"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Enable logging module"
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Enable monitoring module"
  type        = bool
  default     = true
}

variable "enable_waf" {
  description = "Enable WAF module"
  type        = bool
  default     = true
}

variable "enable_frontend" {
  description = "Enable frontend module"
  type        = bool
  default     = true
}

variable "enable_nat" {
  description = "Enable NAT (gateway or instance)"
  type        = bool
  default     = true
}
variable "s3_bucket_name" {
  description = "Frontend S3 bucket name"
  type        = string
  default     = ""
}

variable "backup_window" {
  description = "Backup window for RDS"
  type        = string
  default     = "03:00-05:00"
}

variable "backup_retention_days" {
  description = "RDS backup retention days"
  type        = number
  default     = 7
}

variable "max_allocated_storage" {
  type    = number
  default = 100
}

variable "instance_class" {
  type    = string
  default = "db.t4g.medium"
}

variable "engine_version" {
  type    = string
  default = "15.13"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "frontend_build_dir" {
  type    = string
  default = ""
}

variable "cognito_domain_prefix" {
  type    = string
  default = ""
}

variable "cognito_callback_url" {
  type    = string
  default = ""
}

variable "cognito_logout_url" {
  type    = string
  default = ""
}

variable "admin_email" {
  type    = string
  default = ""
}
variable "allow_jumpbox_to_rds" {
  description = "When true, RDS module will create a security-group-rule allowing the jumpbox SG to access RDS. Keep false when you don't want the rule created automatically."
  type        = bool
  default     = false
}

variable "endpoint_subnet_cidrs" {
  description = "Optional list of CIDRs for dedicated endpoint subnets (one per AZ). If empty, interface endpoints will be placed into the private subnets."
  type        = list(string)
  default     = []
}
# variable "account_id" {}
# variable "account_id" {}
