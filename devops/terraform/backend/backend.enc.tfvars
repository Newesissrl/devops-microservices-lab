# This file is encrypted with SOPS - contains Terraform backend configuration secrets
# To decrypt: sops -d backend.enc.tfvars
# To edit: sops backend.enc.tfvars

# S3 Backend Configuration (SOPS Encrypted)
bucket = "terraform-state-123456789012-shared"
region = "us-west-2"
dynamodb_table = "terraform-state-lock"
encrypt = true

# KMS Key for State Encryption
kms_key_id = "arn:aws:kms:us-west-2:123456789012:key/12345678-90ab-cdef-1234-567890abcdef"

# Access Configuration
role_arn = "arn:aws:iam::123456789012:role/TerraformBackendRole"

# Note: This is a template - actual file should be encrypted with SOPS
# Run: sops -e -i backend.enc.tfvars to encrypt this file