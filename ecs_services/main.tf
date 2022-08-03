# ----- ecs_services/main.tf ----- #

# ----- ECS Core Service ----- #

resource "aws_ecs_service" "ecs_services" {
  for_each                           = var.services
  name                               = "${var.name_prefix}-${each.value.name}-service"
  cluster                            = var.ecs_cluster_id
  task_definition                    = each.value.task_definition
  desired_count                      = each.value.ecs_service.desired_count
  deployment_minimum_healthy_percent = each.value.ecs_service.min_healthy_percent
  deployment_maximum_percent         = each.value.ecs_service.max_percent
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups  = [each.value.security_group]
    subnets          = var.private_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = each.value.target_group
    container_name   = "${var.name_prefix}-${each.value.name}"
    container_port   = each.value.port
  }

}
