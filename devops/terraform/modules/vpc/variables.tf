# VPC Module Variables
# GitOps Principle: All configuration is parameterized and environment-specific
# These variables allow the same infrastructure code to work across dev/staging/prod

variable "project_name" {
  description = "Name of the project - used for resource naming and tagging"
  type        = string
  validation {
    condition     = length(var.project_name) > 0
    error_message = "Project name cannot be empty."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod) - enables environment-specific configurations"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for VPC - defines the IP address range for the entire network"
  type        = string
  default     = "10.0.0.0/16"  # Provides 65,536 IP addresses
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets - where load balancers and NAT gateways reside"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]  # 256 IPs each, across 2 AZs
  validation {
    condition     = length(var.public_subnet_cidrs) >= 2
    error_message = "At least 2 public subnets required for high availability."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets - where application containers run"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]  # 256 IPs each, across 2 AZs
  validation {
    condition     = length(var.private_subnet_cidrs) >= 2
    error_message = "At least 2 private subnets required for high availability."
  }
}