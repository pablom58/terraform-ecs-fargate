# ----- ecs_services/outputs.tf ----- #

output "service_name" {
  value = { for key, value in aws_ecs_service.ecs_services : key => value.name }
}