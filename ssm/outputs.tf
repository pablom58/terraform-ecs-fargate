# ----- ssm/outputs.tf ----- #

output "secrets" {
  value = [for secret in aws_ssm_parameter.secrets.* : { name = var.ssm_secrets[index(aws_ssm_parameter.secrets.*, secret)].name, valueFrom : secret.arn }]
}