# ----- ecs_task_definition/variables.tf ----- #

variable "name_prefix" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "ecs_task_execution_role_arn" {
  type = string
}

variable "ecs_task_role_arn" {
  type = string
}

variable "task_definitions" {}