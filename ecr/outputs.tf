# ----- ecr/outputs.tf ----- #

output "ecr_image" {
  value = { for key, value in aws_ecr_repository.ecr : key => value.repository_url }
}