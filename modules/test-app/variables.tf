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
