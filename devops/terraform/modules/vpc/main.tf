# VPC Module - Creates isolated network infrastructure for the application
# This module demonstrates Infrastructure as Code (IaC) principles in GitOps
# All network resources are defined declaratively and version-controlled

# Data source to get available AWS availability zones
# This ensures our infrastructure adapts to different AWS regions
data "aws_availability_zones" "available" {
  state = "available"
}

# Main VPC - Virtual Private Cloud provides isolated network environment
# CIDR block defines the IP address range for our network
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true  # Required for ECS service discovery
  enable_dns_support   = true  # Required for internal DNS resolution

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
    ManagedBy   = "Terraform"  # GitOps principle: declare management method
  }
}

# Internet Gateway - Provides internet access to public subnets
# Essential for load balancers and NAT gateways
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Public Subnets - Host load balancers and NAT gateways
# Distributed across multiple AZs for high availability
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true  # Auto-assign public IPs

  tags = {
    Name        = "${var.project_name}-public-${count.index + 1}"
    Environment = var.environment
    Type        = "Public"
    ManagedBy   = "Terraform"
  }
}

# Private Subnets - Host application containers (ECS tasks)
# No direct internet access - traffic routed through NAT gateways
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name        = "${var.project_name}-private-${count.index + 1}"
    Environment = var.environment
    Type        = "Private"
    ManagedBy   = "Terraform"
  }
}

# NAT Gateways - Provide outbound internet access for private subnets
# Placed in public subnets, one per AZ for high availability
resource "aws_nat_gateway" "main" {
  count = length(aws_subnet.public)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name        = "${var.project_name}-nat-${count.index + 1}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = length(aws_subnet.public)

  domain = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name        = "${var.project_name}-nat-eip-${count.index + 1}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}