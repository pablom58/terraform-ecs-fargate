# ----- security_groups/variables.tf ----- #

variable "name_prefix" {
  type = string
}

variable "billing_tag" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "containers_sg" {}