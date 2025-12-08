aws_region        = "us-east-1"
environment       = "dev"
project_name      = "cicd-pipeline"
instance_count    = 11 # Using t2.micro (1 vCPU each) = 11 vCPU + bastion (1 vCPU) = 12 vCPU total (within 32 limit)
instance_type     = "t2.micro"
enable_cloudwatch = false
enable_ecr        = false

# VPC Configuration - 15 private subnets (one per instance)
vpc_cidr             = "10.0.0.0/16"
private_subnet_cidrs = [] # Handled in VPC module locals (15 /28 subnets)
public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

# 11 Docker Services - 1 per instance
docker_services = {
  "nodejs-api"       = { port = 3000, index = 0, instance = 0 },
  "python-flask-api" = { port = 5000, index = 1, instance = 1 },
  "go-api"           = { port = 8080, index = 2, instance = 2 },
  "nginx-proxy"      = { port = 80, index = 3, instance = 3 },
  "react-frontend"   = { port = 3001, index = 4, instance = 4 },
  "redis"            = { port = 6379, index = 5, instance = 5 },
  "mongodb"          = { port = 27017, index = 6, instance = 6 },
  "mysql"            = { port = 3306, index = 7, instance = 7 },
  "postgresql"       = { port = 5432, index = 8, instance = 8 },
  "java-spring-boot" = { port = 8081, index = 9, instance = 9 },
  "php-laravel"      = { port = 9000, index = 10, instance = 10 }
}

tags = {
  Environment = "dev"
  Project     = "cicd-pipeline"
  ManagedBy   = "Terraform"
}
