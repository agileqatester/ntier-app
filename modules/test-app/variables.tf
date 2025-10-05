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
