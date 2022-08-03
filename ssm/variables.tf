# ----- ssm/variables.tf ----- #

variable "name_prefix" {
  type = string
}

variable "billing_tag" {
  type = string
}

variable "ssm_secrets" {
  type = list(any)
}

variable "container" {
  type = string
}