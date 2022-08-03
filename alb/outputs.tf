# ----- alb/outputs.tf ----- #

output "alb_dns" {
  value = aws_lb.alb.dns_name
}

output "target_groups" {
  value = { for key, value in aws_lb_target_group.target_groups : key => value.arn }
}