# TFLint Configuration for Terraform Security and Best Practices
# This configuration enables comprehensive Terraform code analysis

# TFLint Core Configuration
config {
  # Enable all available rules by default
  disabled_by_default = false
  
  # Enforce Terraform version constraints
  force = false
  
  # Enable colored output for better readability
  format = "default"
}

# AWS Provider Plugin - Validates AWS-specific best practices
plugin "aws" {
  enabled = true
  version = "0.27.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
  
  # Deep inspection mode for more thorough analysis
  deep_check = true
}

# Terraform Core Rules - Language-specific validations
rule "terraform_deprecated_interpolation" {
  enabled = true
}

rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = true
  format  = "snake_case"
}

rule "terraform_standard_module_structure" {
  enabled = true
}

# AWS-Specific Security Rules
rule "aws_instance_invalid_type" {
  enabled = true
}

rule "aws_instance_previous_type" {
  enabled = true
}

rule "aws_route_specified_multiple_targets" {
  enabled = true
}

rule "aws_security_group_rule_invalid_protocol" {
  enabled = true
}

rule "aws_db_instance_invalid_type" {
  enabled = true
}

rule "aws_elasticache_cluster_invalid_type" {
  enabled = true
}

rule "aws_alb_invalid_security_group" {
  enabled = true
}

rule "aws_alb_invalid_subnet" {
  enabled = true
}

# Cost Optimization Rules
rule "aws_instance_invalid_ami" {
  enabled = true
}

rule "aws_launch_configuration_invalid_image_id" {
  enabled = true
}

# Security Best Practices
rule "aws_security_group_rule_invalid_cidr" {
  enabled = true
}