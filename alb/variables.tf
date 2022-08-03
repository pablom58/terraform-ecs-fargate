# ----- alb/variables.tf ----- #

variable "name_prefix" {
  type = string
}

variable "billing_tag" {
  type = string
}

variable "alb_vpc_id" {
  type = string
}

variable "alb_security_groups" {
  type = list(string)
}

variable "alb_subnets" {
  type = list(string)
}

variable "target_groups" {}