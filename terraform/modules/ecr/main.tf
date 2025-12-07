locals {
  ecr_name = "${lower(var.project_name)}-${lower(var.environment)}"
}

# ECR Repositories for each Docker service
resource "aws_ecr_repository" "services" {
  for_each = toset(var.repositories)

  name                 = "${local.ecr_name}-${each.value}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(
    var.tags,
    {
      Name    = "${title(var.project_name)}-${title(each.value)}"
      Service = each.value
    }
  )

  lifecycle {
    precondition {
      condition     = can(regex("^[a-z0-9_-]+$", each.value))
      error_message = "Repository name must contain only lowercase letters, numbers, hyphens, and underscores."
    }
    prevent_destroy = false
  }
}

# ECR Lifecycle Policy to clean up old images
resource "aws_ecr_lifecycle_policy" "cleanup" {
  for_each = aws_ecr_repository.services

  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Clean untagged images after 7 days"
        selection = {
          tagStatus     = "untagged"
          countType     = "sinceImagePushed"
          countUnit     = "days"
          countNumber   = 7
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
