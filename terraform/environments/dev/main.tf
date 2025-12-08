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

# EC2 Module (Bastion Host & App Instances)
module "ec2" {
  source = "../../modules/ec2"

  environment         = var.environment
  project_name        = var.project_name
  vpc_id              = data.aws_vpc.main.id
  public_subnet_id    = sort(data.aws_subnets.public.ids)[0]
  private_subnet_ids  = sort(data.aws_subnets.private.ids)
  instance_count      = var.instance_count
  instance_type       = var.instance_type
  ecr_repository_urls = { for k, v in data.aws_ecr_repository.services : k => v.repository_url }
  docker_services     = var.docker_services
  aws_region          = var.aws_region

  tags = var.tags

  depends_on = [data.aws_vpc.main]
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
