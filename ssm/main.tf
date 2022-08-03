# ----- ssm/main.tf ----- #

# ----- SSM Parameter Store ----- #

resource "aws_ssm_parameter" "secrets" {
  count       = length(var.ssm_secrets)
  name        = "/${var.name_prefix}/${var.container}/${var.ssm_secrets[count.index].name}"
  description = var.ssm_secrets[count.index].description
  type        = var.ssm_secrets[count.index].type
  value       = var.ssm_secrets[count.index].value

  tags = {
    billing = var.billing_tag
  }
}