# ----- alb/main.tf ----- #

# ----- ALB ----- #

resource "aws_lb" "alb" {
  name               = "${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.alb_security_groups
  subnets            = var.alb_subnets

  enable_deletion_protection = false

  tags = {
    "Name"    = "${var.name_prefix}-alb"
    "billing" = var.billing_tag
  }
}

# ----- ALB Target Groups ----- #

resource "aws_lb_target_group" "target_groups" {
  for_each    = var.target_groups
  name        = "${var.name_prefix}-${each.value.name}-tg"
  port        = each.value.port
  protocol    = each.value.target_group.protocol
  vpc_id      = var.alb_vpc_id
  target_type = "ip"

  health_check {
    path     = each.value.target_group.health_check.path
    matcher  = each.value.target_group.health_check.matcher
    timeout  = each.value.target_group.health_check.timeout
    interval = each.value.target_group.health_check.interval
  }
}

# ----- ALB Listeners ----- #

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_groups["backend"].arn
  }

  # default_action {
  #   type = "redirect"

  #   redirect {
  #     port        = 443
  #     protocol    = "HTTPS"
  #     status_code = "HTTP_301"
  #   }
  # }
}

# resource "aws_lb_listener" "alb_ssl_listener" {
#   load_balancer_arn = aws_lb.alb.arn
#   port              = 443
#   protocol          = "HTTPS"
#   certificate_arn   = var.certificate_arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.target_groups["backend"].arn
#   }
# }