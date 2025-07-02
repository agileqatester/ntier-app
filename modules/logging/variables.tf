variable "name_prefix" {
  description = "Prefix for naming"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "account_id" {
  description = "AWS account ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for OpenSearch"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for OpenSearch"
  type        = string
}

variable "firehose_role_arn" {
  description = "IAM role ARN for Firehose access"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain logs in CloudWatch"
  type        = number
  default     = 7
}