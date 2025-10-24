# Development Environment Infrastructure
# GitOps Principle: Environment-specific configuration using shared modules
# This file defines the complete infrastructure for the development environment

# Terraform Configuration
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # GitOps Best Practice: Remote state storage for team collaboration
  # Uncomment and configure for production use
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "expenses-app/dev/terraform.tfstate"
  #   region = "us-west-2"
  # }
}

# AWS Provider Configuration
provider "aws" {
  region = var.aws_region

  # Default tags applied to all resources
  # GitOps Principle: Consistent tagging for resource management
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      GitRepo     = "expenses-management-system"
    }
  }
}

# Local values for environment-specific configurations
# GitOps Pattern: Centralized configuration management
locals {
  # Development environment uses smaller, cost-optimized settings
  vpc_cidr = "10.0.0.0/16"
  
  # Fewer subnets for development to reduce costs
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
  
  # Common tags for all resources
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# VPC Module - Network Infrastructure
# GitOps Pattern: Reusable modules across environments
module "vpc" {
  source = "../../modules/vpc"

  project_name           = var.project_name
  environment           = var.environment
  vpc_cidr              = local.vpc_cidr
  public_subnet_cidrs   = local.public_subnet_cidrs
  private_subnet_cidrs  = local.private_subnet_cidrs
}

# ECS Module - Container Orchestration Platform
module "ecs" {
  source = "../../modules/ecs"

  project_name        = var.project_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
}

# RDS Instance for Development
# GitOps Note: Development uses smaller instance for cost optimization
resource "aws_db_instance" "mongodb_replacement" {
  identifier = "${var.project_name}-${var.environment}-db"
  
  # Database Configuration
  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.micro"  # Small instance for dev
  
  # Storage Configuration
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type         = "gp2"
  storage_encrypted    = true
  
  # Database Settings
  db_name  = "expenses"
  username = "dbadmin"
  password = var.db_password  # Passed via environment variable
  
  # Network Configuration
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  
  # Backup Configuration (minimal for dev)
  backup_retention_period = 1
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  # Development settings
  skip_final_snapshot = true  # Don't create snapshot on destroy
  deletion_protection = false # Allow deletion in dev
  
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-database"
  })
}

# RDS Subnet Group - Database network configuration
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = module.vpc.private_subnet_ids

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  })
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-${var.environment}-rds-"
  vpc_id      = module.vpc.vpc_id

  # Allow PostgreSQL access from ECS tasks
  ingress {
    description     = "PostgreSQL from ECS tasks"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.ecs.ecs_security_group_id]
  }

  # No outbound rules needed for RDS
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-rds-sg"
  })
}