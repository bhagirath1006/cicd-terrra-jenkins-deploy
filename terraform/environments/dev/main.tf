terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"

  environment    = var.environment
  project_name   = var.project_name
  vpc_cidr       = var.vpc_cidr
  public_subnets = var.public_subnet_cidrs

  tags = var.tags
}

# ECR Module
module "ecr" {
  source = "../../modules/ecr"

  environment  = var.environment
  project_name = var.project_name

  # Create repositories for each docker service
  repositories = keys(var.docker_services)

  tags = var.tags
}

# S3 Module
module "s3" {
  source = "../../modules/s3"

  environment  = var.environment
  project_name = var.project_name

  tags = var.tags
}

# EC2 Module (Bastion Host & App Instances)
module "ec2" {
  source = "../../modules/ec2"

  environment         = var.environment
  project_name        = var.project_name
  vpc_id              = module.vpc.vpc_id
  public_subnet_id    = module.vpc.public_subnet_ids[0]
  private_subnet_ids  = module.vpc.private_subnet_ids
  instance_count      = var.instance_count
  instance_type       = var.instance_type
  ecr_repository_urls = module.ecr.repository_urls
  docker_services     = var.docker_services
  aws_region          = var.aws_region

  tags = var.tags

  depends_on = [module.vpc, module.ecr]
}

# CloudWatch Module
module "cloudwatch" {
  source = "../../modules/cloudwatch"

  count = var.enable_cloudwatch ? 1 : 0

  environment  = var.environment
  project_name = var.project_name
  instance_ids = module.ec2.instance_ids

  tags = var.tags
}
