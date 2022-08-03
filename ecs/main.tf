# ----- ecs/main.tf ----- #

# ----- ECS ----- #

resource "aws_ecs_cluster" "ecs" {
  name = "${var.name_prefix}-ecs-cluster"

  tags = {
    "Name"    = "${var.name_prefix}-ecs-cluster"
    "billing" = var.billing_tag
  }
}