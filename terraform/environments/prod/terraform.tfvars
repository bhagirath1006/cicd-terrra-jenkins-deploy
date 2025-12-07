aws_region        = "us-east-1"
environment       = "prod"
project_name      = "cicd-pipeline"
instance_count    = 15
instance_type     = "t3.large"
enable_cloudwatch = true
enable_ecr        = true

# VPC Configuration
vpc_cidr             = "10.1.0.0/16"
private_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24", "10.1.4.0/24", "10.1.5.0/24"]
public_subnet_cidrs  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]

# 15 Docker Services - 1 per instance
docker_services = {
  "nodejs-api"       = { port = 3000, index = 0 },
  "python-flask-api" = { port = 5000, index = 1 },
  "go-api"           = { port = 8080, index = 2 },
  "nginx-proxy"      = { port = 80, index = 3 },
  "react-frontend"   = { port = 3001, index = 4 },
  "redis"            = { port = 6379, index = 5 },
  "mongodb"          = { port = 27017, index = 6 },
  "mysql"            = { port = 3306, index = 7 },
  "postgresql"       = { port = 5432, index = 8 },
  "java-spring-boot" = { port = 8081, index = 9 },
  "php-laravel"      = { port = 9000, index = 10 },
  "django"           = { port = 8000, index = 11 },
  "fastapi"          = { port = 8002, index = 12 },
  "rabbitmq"         = { port = 5672, index = 13 },
  "elasticsearch"    = { port = 9200, index = 14 }
}

tags = {
  Environment = "prod"
  Project     = "cicd-pipeline"
  ManagedBy   = "Terraform"
  CostCenter  = "Engineering"
}
