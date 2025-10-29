# ECS Module Variables
# GitOps Configuration: Parameterized infrastructure for different environments

variable "project_name" {
  description = "Name of the project - used for resource naming consistency"
  type        = string
}

variable "environment" {
  description = "Environment name - enables environment-specific configurations"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where ECS resources will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the Application Load Balancer"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs where ECS tasks will run"
  type        = list(string)
}