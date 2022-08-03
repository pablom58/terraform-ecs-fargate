# ----- vpc/variables.tf ----- #

variable "vpc_cidr" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "billing_tag" {
  type = string
}

variable "max_subnets" {
  type = number
}

variable "private_subnet_count" {
  type = number
}

variable "public_subnet_count" {
  type = number
}

variable "private_cidrs" {
  type = list(string)
}

variable "public_cidrs" {
  type = list(string)
}