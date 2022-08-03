# ----- security_groups/main.tf ----- #

# ----- ALB Security Group ----- #

resource "aws_security_group" "alb_sg" {
  name   = "${var.name_prefix}-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    protocol         = "tcp"
    from_port        = 443
    to_port          = 443
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    "Name"    = "${var.name_prefix}-alb-sg"
    "billing" = var.billing_tag
  }
}

# ----- ECS Containers Security Groups ----- #

resource "aws_security_group" "containers_security_groups" {
  for_each = var.containers_sg
  name     = "${var.name_prefix}-${each.value.name}-containers-sg"
  vpc_id   = var.vpc_id

  ingress {
    protocol        = each.value.security_group.protocol
    from_port       = each.value.port
    to_port         = each.value.port
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    "Name"    = "${var.name_prefix}-${each.value.name}-containers-sg"
    "billing" = var.billing_tag
  }
}