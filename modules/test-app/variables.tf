variable "name_prefix" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "region" {
  type = string
}

variable "namespace" {
  type    = string
  default = "default"
}

variable "enabled" {
  description = "Enable deploying the test app (used to restrict to dev environment)"
  type        = bool
  default     = false
}

variable "jumpbox_ip" {
  description = "Public IP of the jumpbox for SSH connection"
  type        = string
  default     = ""
}

variable "public_key_path" {
  description = "Path to SSH public key (private key will be derived)"
  type        = string
  default     = ""
}

# Database configuration
variable "enable_db" {
  description = "Enable database connectivity for the test app"
  type        = bool
  default     = false
}

variable "db_secret_name" {
  description = "Name of the Secrets Manager secret containing DB credentials"
  type        = string
  default     = ""
}

variable "db_secret_arn" {
  description = "ARN of the Secrets Manager secret containing DB credentials"
  type        = string
  default     = ""
}

variable "db_host" {
  description = "Database host endpoint"
  type        = string
  default     = ""
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "postgres"
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for EKS"
  type        = string
  default     = ""
}

variable "oidc_provider_url" {
  description = "URL of the OIDC provider for EKS"
  type        = string
  default     = ""
}
