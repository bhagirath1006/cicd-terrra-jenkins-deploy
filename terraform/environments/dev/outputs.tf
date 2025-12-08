output "vpc_id" {
  description = "VPC ID"
  value       = data.aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = sort(data.aws_subnets.public.ids)
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = sort(data.aws_subnets.private.ids)
}

output "bastion_public_ip" {
  description = "Bastion host public IP"
  value       = module.ec2.bastion_public_ip
}

output "app_instance_ids" {
  description = "Application instance IDs"
  value       = module.ec2.instance_ids
}

output "ecr_repository_urls" {
  description = "ECR repository URLs (existing resources)"
  value       = { for k, v in data.aws_ecr_repository.services : k => v.repository_url }
}

output "s3_bucket_names" {
  description = "S3 bucket names (existing resources)"
  value = {
    terraform_state = data.aws_s3_bucket.terraform_state.id
    artifacts       = data.aws_s3_bucket.artifacts.id
    logs            = data.aws_s3_bucket.logs.id
  }
}

output "cloudwatch_dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = try(module.cloudwatch[0].dashboard_url, "N/A")
}
