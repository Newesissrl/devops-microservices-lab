# GitOps Implementation Guide for AWS

This repository demonstrates a complete GitOps implementation for AWS-based microservices deployment without Kubernetes. GitOps is a methodology that uses Git as the single source of truth for declarative infrastructure and application configuration.

## 🎯 GitOps Principles Demonstrated

### 1. **Declarative Configuration**
- All infrastructure defined in Terraform modules (`devops/terraform/`)
- ECS task definitions and services as JSON configurations (`devops/ecs/`)
- Environment-specific configurations in version control (`config/environments/`)

### 2. **Git as Single Source of Truth**
- Infrastructure changes require Git commits and PR approval
- Application deployments triggered by Git pushes
- Configuration changes tracked through Git history

### 3. **Automated Deployment**
- Push to `develop` branch → Automatic deployment to development
- Push to `main` branch → Deployment to staging (with approval gates)
- Production deployments require manual approval and validation

### 4. **Continuous Reconciliation**
- Scheduled drift detection compares actual vs. desired state
- Automatic remediation of configuration drift
- Infrastructure monitoring and alerting

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Developer     │    │   Git Repository │    │   AWS Account   │
│                 │    │                 │    │                 │
│ 1. Code Change  │───▶│ 2. Git Push     │───▶│ 3. Auto Deploy  │
│ 2. Create PR    │    │ 3. Trigger CI/CD│    │ 4. Update State │
│ 3. Review       │    │ 4. Store Config │    │ 5. Monitor      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📁 Repository Structure

```
devops/
├── terraform/                 # Infrastructure as Code
│   ├── modules/               # Reusable Terraform modules
│   │   ├── vpc/              # Network infrastructure
│   │   └── ecs/              # Container orchestration
│   └── environments/         # Environment-specific configs
│       ├── dev/              # Development environment
│       ├── staging/          # Staging environment
│       └── prod/             # Production environment
├── ecs/                      # ECS Configuration
│   ├── task-definitions/     # Container definitions
│   └── services/             # Service configurations
├── cloudformation/           # Alternative IaC approach
└── monitoring/               # Observability configs

config/
└── environments/             # Application configuration
    ├── dev/                  # Development settings
    ├── staging/              # Staging settings
    └── prod/                 # Production settings

.github/workflows/            # GitOps Automation
├── security.yml              # Security scanning
├── build-and-push.yml        # Image building
├── deploy-dev.yml            # Development deployment
├── deploy-staging.yml        # Staging deployment
├── deploy-prod.yml           # Production deployment
└── infrastructure.yml        # Infrastructure management
```

## 🚀 GitOps Workflows

### Development Workflow
1. **Developer pushes to `develop` branch**
2. **Security scanning** runs automatically
3. **Images built** and pushed to registry
4. **Infrastructure updated** if Terraform changes detected
5. **Services deployed** to development environment
6. **Health checks** verify deployment success

### Staging Workflow
1. **PR merged to `main` branch**
2. **All security checks** must pass
3. **Manual approval** required for staging deployment
4. **Blue-green deployment** for zero downtime
5. **Integration tests** run against staging
6. **Promotion gate** for production readiness

### Production Workflow
1. **Manual trigger** with approval workflow
2. **Infrastructure drift check** before deployment
3. **Canary deployment** with traffic shifting
4. **Automated rollback** on failure detection
5. **Post-deployment verification** and monitoring

## 🔧 Setup Instructions

### Prerequisites
- AWS Account with appropriate permissions
- GitHub repository with Actions enabled
- Terraform >= 1.6.0
- AWS CLI configured

### 1. Configure AWS Authentication
```bash
# Create OIDC provider for GitHub Actions
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1

# Create IAM roles for each environment
# See: devops/terraform/iam-roles.tf
```

### 2. Initialize Terraform Backend
```bash
# Create S3 bucket for Terraform state
aws s3 mb s3://terraform-state-YOUR-ACCOUNT-ID-dev
aws s3 mb s3://terraform-state-YOUR-ACCOUNT-ID-staging  
aws s3 mb s3://terraform-state-YOUR-ACCOUNT-ID-prod

# Enable versioning and encryption
aws s3api put-bucket-versioning \
  --bucket terraform-state-YOUR-ACCOUNT-ID-dev \
  --versioning-configuration Status=Enabled
```

### 3. Configure GitHub Secrets
```bash
# Required secrets in GitHub repository settings:
AWS_ACCOUNT_ID=123456789012
DEV_DB_PASSWORD=secure-dev-password
STAGING_DB_PASSWORD=secure-staging-password
PROD_DB_PASSWORD=secure-prod-password
```

### 4. Deploy Infrastructure
```bash
# Development environment
cd devops/terraform/environments/dev
terraform init
terraform plan
terraform apply

# Repeat for staging and production
```

## 🔍 Monitoring and Observability

### CloudWatch Integration
- **Dashboards as Code**: `devops/monitoring/cloudwatch-dashboard.json`
- **Automated Alerting**: Infrastructure and application metrics
- **Log Aggregation**: Centralized logging with structured JSON

### Key Metrics Monitored
- **Infrastructure**: CPU, Memory, Network, Storage
- **Application**: Response time, Error rate, Throughput
- **Business**: User actions, Feature usage, Performance KPIs

### Drift Detection
- **Scheduled Scans**: Weekly infrastructure drift detection
- **Automatic Issues**: GitHub issues created for detected drift
- **Remediation**: Automated or manual drift correction

## 🛡️ Security and Compliance

### Security Scanning
- **SAST**: CodeQL for source code analysis
- **Container Security**: Trivy for vulnerability scanning
- **Infrastructure Security**: Checkov for Terraform validation
- **Secrets Management**: AWS Parameter Store and Secrets Manager

### Compliance Features
- **Audit Trail**: All changes tracked in Git history
- **Approval Gates**: Required reviews for production changes
- **Encryption**: Data encrypted at rest and in transit
- **Access Control**: IAM roles with least privilege principle

## 🔄 Deployment Strategies

### Rolling Deployment (Default)
- **Zero Downtime**: New tasks started before old ones stopped
- **Gradual Rollout**: Configurable deployment speed
- **Health Checks**: Automatic failure detection and rollback

### Blue-Green Deployment (Staging/Production)
- **Complete Environment Swap**: New version deployed to separate environment
- **Traffic Switching**: Instant cutover with rollback capability
- **Testing**: Full validation before traffic switch

### Canary Deployment (Production)
- **Gradual Traffic Shift**: Small percentage of traffic to new version
- **Monitoring**: Real-time metrics comparison
- **Automatic Rollback**: Based on error rate thresholds

## 📚 Training Scenarios

### Scenario 1: Feature Development
1. Create feature branch from `develop`
2. Implement changes and update configurations
3. Create PR with security scans
4. Merge triggers automatic dev deployment
5. Promote to staging after validation

### Scenario 2: Infrastructure Changes
1. Modify Terraform configurations
2. Run `terraform plan` locally
3. Create PR with infrastructure changes
4. Review Terraform plan in PR comments
5. Merge triggers infrastructure update

### Scenario 3: Emergency Hotfix
1. Create hotfix branch from `main`
2. Implement critical fix
3. Fast-track PR approval process
4. Deploy directly to production
5. Backport changes to develop

### Scenario 4: Rollback Procedure
1. Detect production issue
2. Trigger rollback workflow
3. Revert to previous known-good state
4. Investigate and fix root cause
5. Re-deploy with proper testing

## 🎓 Learning Objectives

By working with this GitOps implementation, teams will learn:

1. **Infrastructure as Code**: Managing AWS resources declaratively
2. **Continuous Deployment**: Automated, reliable deployment pipelines
3. **Configuration Management**: Environment-specific settings and secrets
4. **Monitoring and Alerting**: Observability best practices
5. **Security Integration**: Shift-left security in deployment pipelines
6. **Incident Response**: Rollback procedures and troubleshooting
7. **Team Collaboration**: PR-based workflows and approval processes

## 🔗 Additional Resources

- [GitOps Principles](https://opengitops.dev/)
- [AWS ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes following GitOps principles
4. Submit PR with detailed description
5. Ensure all security checks pass
6. Request review from team members

---

**Note**: This implementation serves as a comprehensive training platform for GitOps practices in AWS environments. It demonstrates real-world scenarios while maintaining educational clarity through extensive documentation and comments.