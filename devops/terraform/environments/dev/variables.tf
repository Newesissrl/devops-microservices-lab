# Development Environment Variables
# GitOps Configuration: Environment-specific parameters

variable "aws_region" {
  description = "AWS region for development environment"
  type        = string
  default     = "us-west-2"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "expenses-app"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

# Database password now managed via SOPS in secrets.enc.tfvars
# No need for environment variables or manual secret management