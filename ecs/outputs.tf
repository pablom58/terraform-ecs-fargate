# ----- ecs/output.tf ----- #

output "ecs_cluster_id" {
  value = aws_ecs_cluster.ecs.id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.ecs.name
}