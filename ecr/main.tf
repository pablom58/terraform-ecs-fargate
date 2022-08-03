# ----- ecr/main.tf ----- #

# ----- ECR ----- #

resource "aws_ecr_repository" "ecr" {
  for_each             = var.containers_registry
  name                 = "${var.name_prefix}-${each.value.name}-registry"
  image_tag_mutability = "MUTABLE"

  tags = {
    "Name"    = "${var.name_prefix}-${each.value.name}-registry"
    "billing" = var.billing_tag
  }
}

# ----- ECR Lifecycle Policy ----- #

resource "aws_ecr_lifecycle_policy" "ecr_lifecycle_policy" {
  for_each   = var.containers_registry
  repository = aws_ecr_repository.ecr[each.value.name].name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images."
      action = {
        type = "expire"
      }
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = var.max_image_versions
      }
    }]
  })

  depends_on = [aws_ecr_repository.ecr]
}