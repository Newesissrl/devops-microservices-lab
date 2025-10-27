# AWS Provider Configuration with OIDC Authentication
# This configuration uses AWS OIDC for secure authentication without long-lived credentials

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1.0"
    }
  }

  # Backend configuration using SOPS-encrypted values
  backend "s3" {
    # These values are loaded from backend.enc.tfvars (SOPS encrypted)
    # Decrypt with: sops -d ../../backend/backend.enc.tfvars
  }
}

# SOPS Data Source for Backend Configuration
data "sops_file" "backend_secrets" {
  source_file = "../../backend/backend.enc.tfvars"
  input_type  = "dotenv"
}

# AWS Provider with OIDC Authentication
provider "aws" {
  region = var.aws_region

  # OIDC Authentication - No long-lived credentials needed
  # GitHub Actions will assume this role using OIDC
  assume_role {
    role_arn     = data.sops_file.secrets.data["aws_role_arn"]
    session_name = "terraform-${var.environment}-${random_id.session.hex}"
  }

  # Default tags applied to all resources
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      GitRepo     = "expenses-management-system"
      SOPSManaged = "true"
    }
  }
}

# SOPS Data Source for Environment Secrets
data "sops_file" "secrets" {
  source_file = "secrets.enc.tfvars"
  input_type  = "dotenv"
}

# Random ID for unique session names
resource "random_id" "session" {
  byte_length = 4
}