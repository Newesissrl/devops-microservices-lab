# Development Environment Secrets (SOPS Encrypted)
# To decrypt: sops -d secrets.enc.tfvars
# To edit: sops secrets.enc.tfvars

# Database Secrets
db_password = "dev-secure-password-123"
db_master_username = "dbadmin"

# Application Secrets
jwt_secret = "dev-jwt-secret-key-2024"
api_token = "lakepublisher-token-2024"

# External Service Credentials
rabbitmq_admin_password = "admin123"
monitoring_api_key = "dev-monitoring-key-123"

# Encryption Keys
data_encryption_key = "dev-encryption-key-256bit"

# Note: This is a template - actual file should be encrypted with SOPS
# Run: sops -e -i secrets.enc.tfvars to encrypt this file