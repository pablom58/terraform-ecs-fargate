# ----- security_groups/outputs.tf ----- #

output "alb_sg" {
  value = aws_security_group.alb_sg.id
}

output "containers_sg" {
  value = { for key, value in aws_security_group.containers_security_groups : key => value.id }
}