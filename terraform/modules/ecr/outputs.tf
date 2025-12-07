output "repository_urls" {
  description = "Map of ECR repository URLs"
  value = {
    for name, repo in aws_ecr_repository.services : name => repo.repository_url
  }
}

output "repository_arns" {
  description = "Map of ECR repository ARNs"
  value = {
    for name, repo in aws_ecr_repository.services : name => repo.arn
  }
}

output "registry_id" {
  description = "ECR Registry ID (AWS Account ID)"
  value       = data.aws_caller_identity.current.account_id
}

data "aws_caller_identity" "current" {}
