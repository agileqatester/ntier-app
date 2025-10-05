variable "name_prefix" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "azs" {
  type = list(string)
}

variable "nat_mode" {
  type    = string
  default = "gateway"
}

variable "nat_instance_ami" {
  type    = string
  default = ""
}

variable "nat_instance_type" {
  type    = string
  default = "t3a.nano"
}
