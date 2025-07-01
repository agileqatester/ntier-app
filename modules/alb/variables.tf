variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) > 0
    error_message = "At least one public subnet must be provided."
  }
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS"
  type        = string
}

variable "route53_zone_id" {
  description = "ID of the Route 53 hosted zone"
  type        = string
}

variable "subdomain_name" {
  description = "Subdomain name to assign to the ALB (e.g., app.example.com)"
  type        = string
}
