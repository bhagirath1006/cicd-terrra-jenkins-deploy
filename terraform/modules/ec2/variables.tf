variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID for Bastion"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for app instances"
  type        = list(string)
}

variable "instance_count" {
  description = "Number of application instances"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "ecr_repository_urls" {
  description = "ECR repository URLs"
  type        = map(string)
}

variable "docker_services" {
  description = "Docker services configuration"
  type        = map(object({ port = number, index = number, instance = number }))
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
}
