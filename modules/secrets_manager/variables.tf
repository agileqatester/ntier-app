variable "name_prefix" {
  description = "Prefix for resource naming"
  type        = string
}

variable "db_username" {
  type        = string
  description = "Username for the RDS DB"
  default     = "dbuser"
}