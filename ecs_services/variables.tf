# ----- ecs_services/variables.tf ----- #

variable "name_prefix" {
  type = string
}

variable "ecs_cluster_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "services" {}
