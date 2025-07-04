variable "name_prefix" {
  type        = string
  description = "Prefix for resource naming"
}

variable "s3_bucket_name" {
  type        = string
  description = "Name of the S3 bucket for frontend"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ACM certificate ARN for CloudFront/ALB HTTPS"
}

variable "route53_zone_id" {
  type        = string
  description = "Route 53 hosted zone ID"
}

variable "subdomain_name" {
  type        = string
  description = "Subdomain for frontend (e.g., app.example.com)"
}

variable "frontend_build_dir" {
  type        = string
  description = "Path to local frontend build output (e.g., ./build)"
}

variable "cognito_domain_prefix" {
  type        = string
  description = "Prefix for Cognito hosted domain"
}

variable "cognito_callback_url" {
  type        = string
  description = "OAuth2 redirect URI after Cognito login"
}

variable "cognito_logout_url" {
  type        = string
  description = "Redirect URI after logout"
}

variable "admin_email" {
  type        = string
  description = "Email for initial Cognito admin user"
}

variable "admin_temp_password" {
  type        = string
  description = "Temporary password for admin user"
}

variable "alb_arn" {
  type        = string
  description = "ARN of the ALB"
}

variable "alb_target_group_arn" {
  type        = string
  description = "Target group ARN for forwarding after Cognito auth"
}
