# Secrets Management with SOPS and AWS OIDC

## Overview

This repository implements secure secrets management using **SOPS (Secrets OPerationS)** for encryption and **AWS OIDC** for authentication. This approach eliminates the need for long-lived credentials while keeping sensitive data encrypted in Git.

## Why SOPS and AWS OIDC?

### 🔐 **SOPS Benefits**
- **Git-Native**: Encrypted secrets stored alongside code for version control
- **Selective Encryption**: Only sensitive values are encrypted, not entire files
- **Multiple Backends**: Supports AWS KMS, GCP KMS, Azure Key Vault, PGP
- **Diff-Friendly**: Git diffs show which secrets changed without exposing values
- **Audit Trail**: Complete history of secret changes in Git

### 🔑 **AWS OIDC Benefits**
- **No Long-Lived Credentials**: No AWS access keys stored in GitHub secrets
- **Short-Lived Tokens**: Temporary credentials with automatic expiration
- **Fine-Grained Permissions**: Environment-specific IAM roles
- **Audit Trail**: All actions logged in CloudTrail
- **Secure by Default**: Reduces credential exposure risk

## Repository Structure

```
├── .sops.yaml                           # SOPS configuration and encryption rules
├── devops/terraform/
│   ├── backend/
│   │   └── backend.enc.tfvars          # Encrypted backend configuration
│   └── environments/
│       ├── dev/
│       │   ├── secrets.enc.tfvars      # Encrypted environment secrets
│       │   └── provider.tf            # OIDC provider configuration
│       ├── staging/
│       │   └── secrets.enc.tfvars      # Encrypted staging secrets
│       └── prod/
│           └── secrets.enc.tfvars      # Encrypted production secrets
└── devops/helm/
    ├── sampleproject/
    │   └── secrets.yaml                # Encrypted Helm chart secrets
    └── env/
        ├── dev/secrets.yaml            # Environment-specific Helm secrets
        ├── qa/secrets.yaml
        └── prod/secrets.yaml
```

## Setup Instructions

### 1. Install Required Tools

```bash
# Install SOPS
curl -LO https://github.com/mozilla/sops/releases/latest/download/sops-v3.8.1.linux.amd64
sudo mv sops-v3.8.1.linux.amd64 /usr/local/bin/sops
sudo chmod +x /usr/local/bin/sops

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install Helm SOPS Plugin
helm plugin install https://github.com/jkroepke/helm-secrets
```

### 2. Configure AWS KMS Keys

```bash
# Create KMS keys for each environment
aws kms create-key \
  --description "SOPS encryption key for Terraform backend" \
  --key-usage ENCRYPT_DECRYPT \
  --key-spec SYMMETRIC_DEFAULT

aws kms create-key \
  --description "SOPS encryption key for dev environment" \
  --key-usage ENCRYPT_DECRYPT \
  --key-spec SYMMETRIC_DEFAULT

# Create aliases for easier management
aws kms create-alias \
  --alias-name alias/sops-terraform-backend \
  --target-key-id KEY_ID_HERE

aws kms create-alias \
  --alias-name alias/sops-dev-secrets \
  --target-key-id KEY_ID_HERE
```

### 3. Configure OIDC Provider

```bash
# Create OIDC Identity Provider
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1

# Create IAM role for GitHub Actions
aws iam create-role \
  --role-name GitHubActionsRole-dev \
  --assume-role-policy-document file://oidc-trust-policy.json

# Attach necessary policies
aws iam attach-role-policy \
  --role-name GitHubActionsRole-dev \
  --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
```

### 4. Update .sops.yaml Configuration

```yaml
# Update .sops.yaml with your actual KMS key ARNs and AWS account ID
creation_rules:
  - path_regex: devops/terraform/backend/.*\.enc\.tfvars$
    kms: 'arn:aws:kms:us-west-2:YOUR_ACCOUNT_ID:key/YOUR_KMS_KEY_ID'
```

## Working with Encrypted Secrets

### Terraform Secrets

```bash
# Create new encrypted secret file
sops devops/terraform/environments/dev/secrets.enc.tfvars

# Edit existing encrypted file
sops devops/terraform/environments/dev/secrets.enc.tfvars

# Decrypt and view (without editing)
sops -d devops/terraform/environments/dev/secrets.enc.tfvars

# Encrypt existing plain text file
sops -e -i devops/terraform/environments/dev/secrets.tfvars
```

### Helm Secrets

```bash
# Create new encrypted Helm secrets
sops devops/helm/sampleproject/secrets.yaml

# Deploy Helm chart with encrypted secrets
helm secrets upgrade --install expenses-app devops/helm/sampleproject \
  -f devops/helm/env/dev/values.yaml \
  -f devops/helm/env/dev/secrets.yaml

# Template with secrets (for debugging)
helm secrets template expenses-app devops/helm/sampleproject \
  -f devops/helm/env/dev/values.yaml \
  -f devops/helm/env/dev/secrets.yaml
```

## GitHub Actions Integration

### Workflow Configuration

```yaml
# .github/workflows/infrastructure.yml
permissions:
  id-token: write  # Required for OIDC
  contents: read

jobs:
  terraform:
    steps:
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/GitHubActionsRole-dev
          aws-region: us-west-2

      - name: Decrypt secrets and run Terraform
        run: |
          # SOPS automatically decrypts when Terraform runs
          terraform init
          terraform plan
          terraform apply
```

### Required GitHub Secrets

Only minimal secrets needed in GitHub:

```bash
# GitHub Repository Secrets (Settings → Secrets and variables → Actions)
AWS_ACCOUNT_ID=123456789012  # Your AWS account ID
```

## Security Best Practices

### 🔒 **Encryption at Rest**
- All sensitive values encrypted with AWS KMS
- Different KMS keys per environment
- Automatic key rotation enabled

### 🔑 **Access Control**
- Environment-specific IAM roles
- Least privilege principle
- Time-limited OIDC tokens

### 📊 **Audit and Monitoring**
- All secret access logged in CloudTrail
- Git history tracks secret changes
- KMS key usage monitored

### 🚫 **What NOT to Store in Git**
- Plain text passwords or API keys
- AWS access keys or secret keys
- Private keys or certificates
- Database connection strings with credentials

### ✅ **What IS Safe to Store**
- Encrypted secret files (.enc.tfvars, secrets.yaml)
- Public configuration values
- Non-sensitive environment variables
- Infrastructure definitions

## Troubleshooting

### Common Issues

**SOPS decryption fails:**
```bash
# Check AWS credentials
aws sts get-caller-identity

# Verify KMS key permissions
aws kms describe-key --key-id alias/sops-dev-secrets

# Test KMS access
aws kms encrypt --key-id alias/sops-dev-secrets --plaintext "test"
```

**OIDC authentication fails:**
```bash
# Verify OIDC provider exists
aws iam list-open-id-connect-providers

# Check IAM role trust policy
aws iam get-role --role-name GitHubActionsRole-dev
```

**Terraform backend access denied:**
```bash
# Verify S3 bucket permissions
aws s3 ls s3://terraform-state-bucket

# Check DynamoDB table access
aws dynamodb describe-table --table-name terraform-state-lock
```

## Migration from Existing Secrets

### From Environment Variables

```bash
# 1. Create SOPS file with existing values
cat > secrets.enc.tfvars << EOF
db_password = "$DB_PASSWORD"
jwt_secret = "$JWT_SECRET"
EOF

# 2. Encrypt the file
sops -e -i secrets.enc.tfvars

# 3. Update Terraform to use SOPS data source
# 4. Remove environment variables from CI/CD
```

### From AWS Secrets Manager

```bash
# 1. Export secrets from Secrets Manager
aws secretsmanager get-secret-value --secret-id prod/database/password

# 2. Create SOPS file with exported values
# 3. Update applications to use new secret source
# 4. Delete old secrets from Secrets Manager
```

## Benefits Achieved

### 🚀 **Developer Experience**
- Secrets managed alongside code
- No manual secret distribution
- Environment parity guaranteed

### 🔐 **Security Posture**
- No long-lived credentials
- Encrypted secrets in Git
- Comprehensive audit trail

### 🔄 **Operational Efficiency**
- Automated secret rotation
- Consistent deployment process
- Reduced secret sprawl

### 💰 **Cost Optimization**
- No AWS Secrets Manager charges
- Reduced KMS API calls
- Simplified secret management

This implementation provides enterprise-grade secrets management while maintaining developer productivity and security best practices.