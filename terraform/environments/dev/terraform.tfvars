aws_region        = "us-east-1"
environment       = "dev"
project_name      = "cicd-pipeline"
instance_count    = 3 # Using t2.micro (1 vCPU each) = 3 vCPU + bastion (1 vCPU) = 4 vCPU total (minimal)
instance_type     = "t2.micro"
enable_cloudwatch = false
enable_ecr        = false

# VPC Configuration - 15 private subnets (one per instance)
vpc_cidr             = "10.0.0.0/16"
private_subnet_cidrs = [] # Handled in VPC module locals (15 /28 subnets)
public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

# 3 Docker Services - minimal setup
docker_services = {
  "nodejs-api"       = { port = 3000, index = 0, instance = 0 },
  "python-flask-api" = { port = 5000, index = 1, instance = 1 },
  "go-api"           = { port = 8080, index = 2, instance = 2 }
}

tags = {
  Environment = "dev"
  Project     = "cicd-pipeline"
  ManagedBy   = "Terraform"
}
