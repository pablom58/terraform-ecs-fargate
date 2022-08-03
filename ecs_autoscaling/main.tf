# ----- ecs_autoscaling/main.tf ----- #

# ----- Autoscaling Targets ----- #

resource "aws_appautoscaling_target" "autoscaling_target" {
  for_each           = var.services
  max_capacity       = each.value.ecs_autoscaling.max_capacity
  min_capacity       = each.value.ecs_autoscaling.min_capacity
  resource_id        = "service/${var.ecs_cluster_name}/${each.value.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# ----- Memory Autoscaling Policy ----- #

resource "aws_appautoscaling_policy" "memory_autoscaling_policy" {
  for_each           = var.services
  name               = "${var.name_prefix}-${each.value.name}-memory-autoscaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.autoscaling_target[each.value.name].resource_id
  scalable_dimension = aws_appautoscaling_target.autoscaling_target[each.value.name].scalable_dimension
  service_namespace  = aws_appautoscaling_target.autoscaling_target[each.value.name].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    target_value = each.value.ecs_autoscaling.memory_target_value
  }

  depends_on = [aws_appautoscaling_target.autoscaling_target]
}

# ----- CPU Autoscaling Policy ----- #

resource "aws_appautoscaling_policy" "core_cpu_policy" {
  for_each           = var.services
  name               = "${var.name_prefix}-${each.value.name}-cpu-autoscaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.autoscaling_target[each.value.name].resource_id
  scalable_dimension = aws_appautoscaling_target.autoscaling_target[each.value.name].scalable_dimension
  service_namespace  = aws_appautoscaling_target.autoscaling_target[each.value.name].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = each.value.ecs_autoscaling.cpu_target_value
  }

  depends_on = [aws_appautoscaling_target.autoscaling_target]
}