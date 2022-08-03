# ----- ecs_task_definition/outputs.tf ----- #

output "task_definitions_arn" {
  value = { for key, value in aws_ecs_task_definition.task_definitions : key => value.arn }
}