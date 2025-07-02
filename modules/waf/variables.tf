variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "scope" {
  description = "Scope of WAF (REGIONAL for ALB or CLOUDFRONT)"
  type        = string
  default     = "REGIONAL"
}

variable "resource_arn" {
  description = "ARN of the resource (ALB or CloudFront) to associate WAF"
  type        = string
}
