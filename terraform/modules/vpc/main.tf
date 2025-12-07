locals {
  # Use functions for naming conventions
  vpc_name            = "${lower(var.project_name)}-vpc-${var.environment}"
  public_subnet_name  = "${title(var.project_name)}-Public-Subnet"
  private_subnet_name = "${title(var.project_name)}-Private-Subnet"
  
  # Dynamically generate 15 subnet CIDR blocks from VPC CIDR
  # cidrsubnets() divides 10.0.0.0/16 into 15 /28 subnets (each with 16 IPs, 15 usable)
  private_subnets = cidrsubnets(var.vpc_cidr, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12)
  
  # Example output:
  # 10.0.0.0/28, 10.0.0.16/28, 10.0.0.32/28, ... 10.0.0.224/28
  # Each /28 = 16 IPs with 15 usable for EC2 instances
}

# Data source for availability zones - Filter to only supported zones for t3 instances
data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "zone-name"
    values = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1f"]
  }
}

# VPC with preconditions
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    {
      Name = local.vpc_name
    }
  )
}

# Public Subnets with count meta-argument
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${local.public_subnet_name}-${count.index + 1}"
      Type = "Public"
    }
  )

  lifecycle {
    ignore_changes = [map_public_ip_on_launch]
  }
}

# Private Subnets with count meta-argument - 15 subnets for 15 instances
resource "aws_subnet" "private" {
  count             = 15
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]

  tags = merge(
    var.tags,
    {
      Name = "${local.private_subnet_name}-${count.index}"
      Type = "Private"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${local.vpc_name}-igw"
    }
  )
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  count  = length(var.public_subnets)
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${local.vpc_name}-eip-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# NAT Gateways for Private Subnets
resource "aws_nat_gateway" "main" {
  count         = length(var.public_subnets)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    var.tags,
    {
      Name = "${local.vpc_name}-nat-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${local.vpc_name}-public-rt"
    }
  )
}

# Public Route Table Associations
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Tables (one per NAT Gateway for redundancy - 15 subnets)
resource "aws_route_table" "private" {
  count  = 15
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index % length(aws_nat_gateway.main)].id
  }

  tags = merge(
    var.tags,
    {
      Name = "${local.vpc_name}-private-rt-${count.index}"
    }
  )
}

# Private Route Table Associations - 15 subnets to route tables
resource "aws_route_table_association" "private" {
  count          = 15
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
