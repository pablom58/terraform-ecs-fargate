# ----- locals.tf ----- #

locals {
  billing_tag = "pmvs"
  name_prefix = "pmvs-ecs"
}

locals {
  containers = {
    backend = {
      name = "backend"
      port = 3000

      security_group = {
        protocol = "tcp"
      }

      target_group = {
        protocol = "HTTP"
        health_check = {
          path     = "/health"
          matcher  = 200
          timeout  = 5
          interval = 30
        }
      }

      task_definition = {
        cpu                       = 512
        memory                    = 1024
        health_check_path         = "http://localhost:3000/health"
        health_check_timeout      = 5
        health_check_interval     = 30
        health_check_retries      = 5
        health_check_start_period = 15
        image_tag                 = "latest"
      }

      ecs_service = {
        min_healthy_percent = 50
        max_percent         = 200
        desired_count       = 1
      }

      ecs_autoscaling = {
        min_capacity        = 1
        max_capacity        = 2
        cpu_target_value    = 60
        memory_target_value = 80
      }

      ssm_secrets = [
        # {
        #   name        = "PORT"
        #   description = ""
        #   type        = "String"
        #   value       = 5000
        # },
      ]
    }
  }
}
