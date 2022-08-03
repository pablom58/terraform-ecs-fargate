# ----- ecs_task_definition/main.tf ----- #

# ----- ECS Task Definitions ----- #

resource "aws_ecs_task_definition" "task_definitions" {
  for_each                 = var.task_definitions
  family                   = "${var.name_prefix}-${each.value.name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value.task_definition.cpu
  memory                   = each.value.task_definition.memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "${var.name_prefix}-${each.value.name}"
      image     = each.value.image
      essential = true
      secrets   = each.value.secrets
      portMappings = [{
        protocol      = "tcp"
        containerPort = each.value.port
        hostPort      = each.value.port
      }]
      healthCheck = {
        retries = each.value.task_definition.health_check_retries
        command = [
          "curl",
          "-f",
          each.value.task_definition.health_check_path
        ],
        timeout     = each.value.task_definition.health_check_timeout
        interval    = each.value.task_definition.health_check_interval
        startPeriod = each.value.task_definition.health_check_start_period
      }
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-create-group"  = "true",
          "awslogs-group"         = "${var.name_prefix}-${each.value.name}-logs",
          "awslogs-region"        = var.aws_region,
          "awslogs-stream-prefix" = "${var.name_prefix}-${each.value.name}"
        }
      }
    }
  ])
}