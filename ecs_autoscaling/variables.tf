# ----- ecs_autoscaling/variables.tf ----- #

variable "name_prefix" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
}

variable "services" {}