locals {
  bastion_name = "${lower(var.project_name)}-bastion-${var.environment}"
  app_name     = "${lower(var.project_name)}-app"
}

# Get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group for Bastion Host
resource "aws_security_group" "bastion" {
  name_prefix = "${title(var.project_name)}-Bastion-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # In production, restrict this!
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Jenkins port
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${title(var.project_name)}-Bastion-SG"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group for App Instances
resource "aws_security_group" "app" {
  name_prefix = "${title(var.project_name)}-App-"
  vpc_id      = var.vpc_id

  # SSH from Bastion
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  # API Services
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "nodejs-api"
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "python-flask-api"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "go-api"
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "java-spring-boot"
  }

  ingress {
    from_port   = 8002
    to_port     = 8002
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "fastapi"
  }

  # Web Services
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "nginx-proxy"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "https"
  }

  ingress {
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "react-frontend"
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "php-laravel"
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "django"
  }

  # Data Services (Internal Communication via separate rules)
  # redis, mongodb, mysql, postgresql, rabbitmq, elasticsearch
  # These will be added via aws_security_group_rule to avoid self-reference

  # Dynamic ingress rules for all docker services
  dynamic "ingress" {
    for_each = var.docker_services
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = ingress.key
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${title(var.project_name)}-App-SG"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# IAM Role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name_prefix = "${upper(var.environment)}_EC2_Role_"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Policy for ECR access
resource "aws_iam_role_policy" "ecr_policy" {
  name_prefix = "${upper(var.environment)}_ECR_Policy_"
  role        = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Policy for CloudWatch
resource "aws_iam_role_policy" "cloudwatch_policy" {
  name_prefix = "${upper(var.environment)}_CloudWatch_Policy_"
  role        = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name_prefix = "${upper(var.environment)}_EC2_Profile_"
  role        = aws_iam_role.ec2_role.name
}

# Bastion Host with Jenkins using userdata
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true

  user_data = base64encode(templatefile("${path.module}/userdata-jenkins.sh", {
    environment  = var.environment
    project_name = var.project_name
    ecr_urls     = jsonencode(var.ecr_repository_urls)
  }))

  tags = merge(
    var.tags,
    {
      Name = local.bastion_name
      Role = "Bastion"
    }
  )

  depends_on = [aws_iam_instance_profile.ec2_profile]
}

# Application Instances with count - 1 service per instance
resource "aws_instance" "app" {
  count                  = var.instance_count
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  # Get service name and port for this instance
  user_data = base64encode(templatefile("${path.module}/userdata-app.sh", {
    environment  = var.environment
    project_name = var.project_name
    instance_id  = count.index + 1
    service_name = keys(var.docker_services)[count.index]
    service_port = var.docker_services[keys(var.docker_services)[count.index]].port
    ecr_registry = try(split("/", var.ecr_repository_urls[keys(var.docker_services)[count.index]])[0], "")
  }))

  tags = merge(
    var.tags,
    {
      Name    = "${local.app_name}-${keys(var.docker_services)[count.index]}"
      Role    = "AppServer"
      Service = keys(var.docker_services)[count.index]
    }
  )

  depends_on = [aws_iam_instance_profile.ec2_profile]
}

# Inter-service communication rules (avoid self-reference in security group)
resource "aws_security_group_rule" "inter_service_tcp" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = aws_security_group.app.id
  source_security_group_id = aws_security_group.app.id
  description       = "inter-service-communication-tcp"
}

resource "aws_security_group_rule" "inter_service_udp" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "udp"
  security_group_id = aws_security_group.app.id
  source_security_group_id = aws_security_group.app.id
  description       = "inter-service-communication-udp"
}

# Dynamic security group rules for all docker services internal communication
resource "aws_security_group_rule" "app_services" {
  for_each = var.docker_services

  type              = "ingress"
  from_port         = each.value.port
  to_port           = each.value.port
  protocol          = "tcp"
  security_group_id = aws_security_group.app.id
  source_security_group_id = aws_security_group.app.id
  description       = "internal-${each.key}"
}
