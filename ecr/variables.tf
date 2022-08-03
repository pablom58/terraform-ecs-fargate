# ----- ecr/variables.tf ----- #

variable "name_prefix" {
  type = string
}

variable "billing_tag" {
  type = string
}

variable "max_image_versions" {
  type = number
}

variable "containers_registry" {}