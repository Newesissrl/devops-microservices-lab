# DevSecOps Implementation Guide

## What is DevSecOps?

DevSecOps integrates security practices into the DevOps pipeline, making security a shared responsibility throughout the software development lifecycle. It shifts security "left" in the development process, catching vulnerabilities early and automating security checks.

## Core DevSecOps Principles

### 1. **Shift-Left Security**
Security testing and validation happens early in the development process, not just before production.

### 2. **Security as Code**
Security policies, configurations, and tests are defined as code and version-controlled.

### 3. **Continuous Security**
Automated security scanning and monitoring throughout the entire pipeline.

### 4. **Shared Responsibility**
Security is everyone's responsibility, not just the security team's.

## DevSecOps Implementation in This Repository

### 🔍 **Static Application Security Testing (SAST)**

**File**: `.github/workflows/security.yml` (lines 15-30)
```yaml
static-analysis:
  - name: Run CodeQL Analysis
    uses: github/codeql-action/init@v3
    with:
      languages: javascript, python, csharp
```

**Implementation**:
- **What**: Analyzes source code for security vulnerabilities without executing it
- **When**: Every pull request and push to main branches
- **Languages**: JavaScript (frontend/backend), Python (processor), C# (lakepublisher)
- **Tool**: GitHub CodeQL for comprehensive vulnerability detection
- **Integration**: Results appear in GitHub Security tab and block PR merges if critical issues found

### 🐳 **Container Security Scanning**

**File**: `.github/workflows/security.yml` (lines 32-60)
```yaml
container-security:
  - name: Run Trivy vulnerability scanner
    uses: aquasecurity/trivy-action@master
    with:
      image-ref: ${{ matrix.service }}:test
      format: sarif
```

**Implementation**:
- **What**: Scans Docker images for known vulnerabilities in OS packages and dependencies
- **When**: Every container build before pushing to registry
- **Scope**: All 4 services (backend, frontend, processor, lakepublisher)
- **Tool**: Trivy scanner for comprehensive vulnerability database
- **Integration**: SARIF format results uploaded to GitHub Security tab

### 🏗️ **Infrastructure Security Scanning**

**File**: `.github/workflows/security.yml` (lines 62-95)
```yaml
kubernetes-security:
  - name: Run Checkov scan on K8s manifests
    uses: bridgecrewio/checkov-action@master
```

**File**: `.github/workflows/infrastructure.yml` (lines 85-95)
```yaml
- name: Security Scan
  uses: bridgecrewio/checkov-action@master
  with:
    directory: devops/terraform/environments/${{ matrix.environment }}
    framework: terraform
```

**Implementation**:
- **What**: Validates infrastructure configurations against security best practices
- **Scope**: 
  - Kubernetes manifests in `devops/kubernetes/`
  - Terraform configurations in `devops/terraform/`
- **Tool**: Checkov for policy-as-code security validation
- **Policies**: CIS benchmarks, AWS security best practices, OWASP guidelines

### 🔐 **Secrets Management**

**Files**: 
- `devops/ecs/task-definitions/backend.json` (lines 45-55)
- `devops/terraform/environments/dev/main.tf` (lines 95-100)

```json
"secrets": [
  {
    "name": "DATABASE_URL",
    "valueFrom": "/expenses-app/dev/database-url"
  }
]
```

**Implementation**:
- **What**: Secure storage and injection of sensitive configuration
- **Storage**: AWS Parameter Store and Secrets Manager
- **Access**: IAM roles with least privilege principle
- **Rotation**: Automated secret rotation capabilities
- **Audit**: All secret access logged in CloudTrail

### 🛡️ **Security Hardening**

**Files**:
- `devops/terraform/modules/vpc/main.tf` - Network security
- `devops/terraform/modules/ecs/main.tf` - Container security
- `packages/*/Dockerfile` - Container hardening

**Network Security** (`devops/terraform/modules/vpc/main.tf`):
```hcl
# Private subnets for application containers
resource "aws_subnet" "private" {
  # No direct internet access
  map_public_ip_on_launch = false
}
```

**Container Security** (`devops/terraform/modules/ecs/main.tf`):
```hcl
# Security group restricts container network access
resource "aws_security_group" "ecs_tasks" {
  # Only allow traffic from ALB
  ingress {
    security_groups = [aws_security_group.alb.id]
  }
}
```

**Container Hardening** (`packages/*/Dockerfile`):
```dockerfile
# Run as non-root user
USER nobody
# Multi-stage builds exclude dev dependencies
FROM node:24.6.0-alpine AS production
```

### 🔒 **Access Control and Authentication**

**Files**:
- `.github/workflows/*.yml` - OIDC authentication
- `devops/terraform/environments/*/main.tf` - IAM roles

**OIDC Authentication** (`.github/workflows/deploy-dev.yml`):
```yaml
permissions:
  id-token: write  # Required for OIDC authentication
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::${{ secrets.AWS_ACCOUNT_ID }}:role/GitHubActionsRole
```

**Implementation**:
- **What**: Secure authentication without long-lived credentials
- **Method**: OpenID Connect (OIDC) with GitHub Actions
- **Benefits**: No AWS access keys stored in GitHub secrets
- **Scope**: Environment-specific IAM roles with minimal permissions

### 📊 **Security Monitoring and Alerting**

**File**: `devops/monitoring/cloudwatch-dashboard.json`
```json
"_alerting_integration": {
  "critical_alarms": [
    "High CPU utilization (>80%)",
    "High error rate (>5%)",
    "Database connection failures",
    "Service task count below minimum"
  ]
}
```

**Implementation**:
- **What**: Continuous monitoring for security and operational issues
- **Metrics**: Application performance, infrastructure health, security events
- **Alerting**: Automated notifications for anomalies and security incidents
- **Integration**: CloudWatch alarms with SNS notifications

### 🔄 **Compliance and Audit**

**Files**: All files in the repository contribute to compliance
- Git history provides complete audit trail
- PR reviews ensure change approval
- Automated testing validates security controls

**Compliance Features**:
- **Audit Trail**: Every change tracked in Git with author, timestamp, and reason
- **Approval Gates**: Production changes require manual approval
- **Encryption**: Data encrypted at rest (RDS, S3) and in transit (HTTPS, TLS)
- **Access Logging**: All AWS API calls logged in CloudTrail

## DevSecOps Pipeline Flow

### 1. **Development Phase**
```
Code → SAST Scan → Unit Tests → Security Tests → Commit
```
**Files**: `.github/workflows/security.yml`, `packages/*/tests/`

### 2. **Build Phase**
```
Dockerfile → Container Build → Vulnerability Scan → Registry Push
```
**Files**: `packages/*/Dockerfile`, `.github/workflows/build-and-push.yml`

### 3. **Infrastructure Phase**
```
Terraform → Security Scan → Plan Review → Apply → Compliance Check
```
**Files**: `devops/terraform/`, `.github/workflows/infrastructure.yml`

### 4. **Deployment Phase**
```
Deploy → Health Check → Security Validation → Monitor
```
**Files**: `.github/workflows/deploy-*.yml`, `devops/monitoring/`

## Security Controls Matrix

| Security Control | Implementation | Files | Automation |
|------------------|----------------|-------|------------|
| **Code Scanning** | CodeQL SAST | `.github/workflows/security.yml` | ✅ Automated |
| **Dependency Scanning** | Trivy container scan | `.github/workflows/security.yml` | ✅ Automated |
| **Infrastructure Security** | Checkov policy scan | `.github/workflows/infrastructure.yml` | ✅ Automated |
| **Secrets Management** | AWS Parameter Store | `devops/ecs/task-definitions/` | ✅ Automated |
| **Access Control** | IAM roles + OIDC | `.github/workflows/*.yml` | ✅ Automated |
| **Network Security** | VPC + Security Groups | `devops/terraform/modules/` | ✅ Automated |
| **Encryption** | RDS + S3 encryption | `devops/terraform/environments/` | ✅ Automated |
| **Monitoring** | CloudWatch + Alarms | `devops/monitoring/` | ✅ Automated |
| **Audit Logging** | Git + CloudTrail | All files | ✅ Automated |
| **Compliance** | Policy as Code | `devops/terraform/` | ✅ Automated |

## DevSecOps Benefits Achieved

### 🚀 **Early Detection**
- Security issues caught in development, not production
- **Cost Reduction**: 100x cheaper to fix vulnerabilities early
- **Files**: All security workflow files enable early detection

### 🔄 **Continuous Security**
- Automated security checks on every change
- **No Manual Gates**: Security doesn't slow down development
- **Files**: Workflow automation ensures continuous validation

### 📈 **Scalable Security**
- Security scales with development velocity
- **Consistent Application**: Same security standards across all environments
- **Files**: Terraform modules ensure consistent security controls

### 🎯 **Risk Reduction**
- Multiple layers of security controls
- **Defense in Depth**: Network, container, application, and data security
- **Files**: Comprehensive security implementation across all components

## Getting Started with DevSecOps

1. **Review Security Workflows**: Examine `.github/workflows/security.yml`
2. **Understand Security Controls**: Check `devops/terraform/modules/`
3. **Test Security Scanning**: Create a PR and observe security checks
4. **Monitor Security Metrics**: Review `devops/monitoring/cloudwatch-dashboard.json`
5. **Practice Incident Response**: Use monitoring and alerting configurations

This repository demonstrates a complete DevSecOps implementation, showing how security can be seamlessly integrated into modern development and deployment practices without sacrificing velocity or developer experience.