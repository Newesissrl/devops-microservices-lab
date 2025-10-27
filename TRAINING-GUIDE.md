# Complete DevOps Training Guide

## Overview

This repository provides a comprehensive hands-on training experience for modern DevOps, GitOps, and DevSecOps practices. The training is designed to take participants from basic containerization concepts to enterprise-grade deployment pipelines with security integration.

## Training Prerequisites

### **Technical Requirements**
- Basic understanding of containerization (Docker)
- Familiarity with Git workflows
- AWS account with administrative access
- GitHub account with Actions enabled
- Local development environment (Docker, Git, text editor)

### **Knowledge Prerequisites**
- Basic Linux/Unix command line
- Understanding of web applications and APIs
- Familiarity with YAML and JSON formats
- Basic networking concepts (HTTP, DNS, load balancing)

## Training Modules

### **Module 1: Foundation (Week 1)**
**Objective**: Understand the application architecture and local development setup

#### **Day 1-2: Application Architecture**
- Review microservices architecture
- Understand service communication patterns
- Explore the expense management business logic
- Set up local development environment

**Hands-on Labs**:
```bash
# Clone and explore the repository
git clone <repository-url>
cd sampleproject

# Review application structure
ls -la packages/
cat README.md

# Start local development environment
docker-compose up --build
```

#### **Day 3-4: Containerization Deep Dive**
- Multi-stage Dockerfiles analysis
- Container security best practices
- Build optimization techniques
- Development vs production configurations

**Hands-on Labs**:
```bash
# Analyze Dockerfiles
cat packages/backend/Dockerfile
cat packages/backend/Dockerfile.dev

# Build and test containers
docker build -t backend:test packages/backend --target production
docker run --rm backend:test npm test
```

#### **Day 5: Container Orchestration**
- Docker Compose orchestration
- Service networking and dependencies
- Health checks and monitoring
- Volume management and persistence

**Hands-on Labs**:
```bash
# Explore compose configuration
cat docker-compose.yml
cat docker-compose.override.yml

# Test different environments
docker-compose -f docker-compose.yml up  # Production
docker-compose up  # Development with override
```

### **Module 2: Infrastructure as Code (Week 2)**
**Objective**: Master Terraform and AWS infrastructure management

#### **Day 1-2: Terraform Fundamentals**
- Terraform modules and best practices
- State management and remote backends
- Resource dependencies and lifecycle
- Environment-specific configurations

**Hands-on Labs**:
```bash
# Explore Terraform structure
ls -la devops/terraform/
cat devops/terraform/modules/vpc/main.tf

# Initialize and plan infrastructure
cd devops/terraform/environments/dev
terraform init
terraform plan
```

#### **Day 3-4: AWS Infrastructure**
- VPC design and networking
- ECS container orchestration
- Application Load Balancer configuration
- RDS database setup and security

**Hands-on Labs**:
```bash
# Deploy development infrastructure
terraform apply

# Verify AWS resources
aws ecs list-clusters
aws elbv2 describe-load-balancers
```

#### **Day 5: Infrastructure Security**
- Security groups and network ACLs
- IAM roles and policies
- Encryption at rest and in transit
- Compliance and governance

**Hands-on Labs**:
```bash
# Review security configurations
cat devops/terraform/modules/ecs/main.tf | grep security_group
aws iam list-roles | grep ECS
```

### **Module 3: Secrets Management & Security (Week 3)**
**Objective**: Implement enterprise-grade secrets management and security practices

#### **Day 1-2: SOPS Implementation**
- SOPS installation and configuration
- AWS KMS key management
- Encryption and decryption workflows
- Git integration best practices

**Hands-on Labs**:
```bash
# Install and configure SOPS
curl -LO https://github.com/mozilla/sops/releases/latest/download/sops-v3.8.1.linux.amd64
sudo mv sops-v3.8.1.linux.amd64 /usr/local/bin/sops

# Create and encrypt secrets
sops devops/terraform/environments/dev/secrets.enc.tfvars
```

#### **Day 3-4: AWS OIDC Authentication**
- OpenID Connect provider setup
- IAM roles for GitHub Actions
- Trust policies and permissions
- Environment-specific access control

**Hands-on Labs**:
```bash
# Create OIDC provider
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com

# Create IAM roles
aws iam create-role \
  --role-name GitHubActionsRole-dev \
  --assume-role-policy-document file://oidc-trust-policy.json
```

#### **Day 5: Security Scanning Integration**
- SAST with CodeQL
- Container vulnerability scanning with Trivy
- Infrastructure security with TFLint, tfsec, Checkov
- Security pipeline integration

**Hands-on Labs**:
```bash
# Test security scanning locally
tflint devops/terraform/environments/dev/
tfsec devops/terraform/environments/dev/
checkov -d devops/terraform/environments/dev/
```

### **Module 4: GitOps Implementation (Week 4)**
**Objective**: Implement complete GitOps workflows with approval gates

#### **Day 1-2: Development Workflow**
- Git-driven deployments
- Automated infrastructure updates
- Configuration management
- Health check validation

**Hands-on Labs**:
```bash
# Test development deployment
git checkout -b feature/test-deployment
echo "# Test change" >> README.md
git add . && git commit -m "Test deployment"
git push origin feature/test-deployment

# Merge to develop and observe deployment
git checkout develop
git merge feature/test-deployment
git push origin develop
```

#### **Day 3-4: Staging and Production Workflows**
- Approval gates and environments
- Blue-green deployment strategies
- Integration testing automation
- Performance validation

**Hands-on Labs**:
```bash
# Trigger staging deployment
git push origin main

# Monitor deployment in GitHub Actions
# Test staging environment
curl https://staging-alb-dns/api/

# Trigger production deployment (manual)
# Use GitHub Actions UI with staging-validated image tag
```

#### **Day 5: Advanced Deployment Strategies**
- Canary deployments with traffic shifting
- Automated rollback mechanisms
- Infrastructure drift detection
- Disaster recovery procedures

**Hands-on Labs**:
```bash
# Test canary deployment
# Use GitHub Actions UI to deploy with canary strategy

# Monitor deployment health
aws ecs describe-services --cluster expenses-app-prod

# Test rollback procedure
# Simulate failure and observe automatic rollback
```

### **Module 5: Monitoring & Observability (Week 5)**
**Objective**: Implement comprehensive monitoring and alerting

#### **Day 1-2: CloudWatch Integration**
- Dashboards as code
- Custom metrics and alarms
- Log aggregation and analysis
- Performance monitoring

**Hands-on Labs**:
```bash
# Deploy monitoring dashboard
aws cloudwatch put-dashboard \
  --dashboard-name ExpensesApp-Dev \
  --dashboard-body file://devops/monitoring/cloudwatch-dashboard.json

# Create custom alarms
aws cloudwatch put-metric-alarm \
  --alarm-name "High-CPU-Usage" \
  --alarm-description "ECS CPU usage too high"
```

#### **Day 3-4: Application Monitoring**
- Health check endpoints
- Business metrics tracking
- Error monitoring and alerting
- Performance optimization

**Hands-on Labs**:
```bash
# Test health endpoints
curl http://alb-dns/
curl http://alb-dns/api/

# Generate test traffic and monitor metrics
for i in {1..100}; do curl http://alb-dns/api/expenses; done
```

#### **Day 5: Incident Response**
- Alerting and notification setup
- Runbook automation
- Post-incident analysis
- Continuous improvement

**Hands-on Labs**:
```bash
# Simulate incident
# Stop ECS service and observe alerting

# Practice incident response
# Follow runbook procedures
# Document lessons learned
```

## Assessment and Certification

### **Practical Assessment**
Students must complete a capstone project demonstrating:

1. **Infrastructure Deployment**: Deploy complete infrastructure using Terraform
2. **Security Implementation**: Configure SOPS encryption and OIDC authentication
3. **GitOps Workflow**: Implement automated deployment pipeline
4. **Security Integration**: Set up comprehensive security scanning
5. **Monitoring Setup**: Configure dashboards and alerting
6. **Incident Response**: Demonstrate rollback and recovery procedures

### **Assessment Criteria**
- **Technical Implementation** (40%): Correct configuration and deployment
- **Security Best Practices** (30%): Proper secrets management and security controls
- **Documentation** (20%): Clear documentation and runbooks
- **Troubleshooting** (10%): Ability to diagnose and resolve issues

### **Certification Levels**

#### **DevOps Foundation** (Modules 1-2)
- Container orchestration
- Infrastructure as Code
- Basic CI/CD pipelines

#### **GitOps Practitioner** (Modules 1-4)
- Git-driven deployments
- Secrets management
- Security integration
- Multi-environment workflows

#### **DevSecOps Expert** (All Modules)
- Enterprise security practices
- Advanced deployment strategies
- Comprehensive monitoring
- Incident response

## Resources and References

### **Documentation**
- [README.md](README.md) - Complete project overview
- [GitOps.md](GitOps.md) - GitOps implementation guide
- [DevSecOps.md](DevSecOps.md) - Security integration documentation
- [SECRETS-MANAGEMENT.md](SECRETS-MANAGEMENT.md) - SOPS and OIDC guide

### **External Resources**
- [GitOps Principles](https://opengitops.dev/)
- [AWS ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [SOPS Documentation](https://github.com/mozilla/sops)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

### **Community and Support**
- GitHub Discussions for Q&A
- Weekly office hours for troubleshooting
- Slack channel for real-time support
- Monthly webinars for advanced topics

This training guide provides a structured path to mastering modern DevOps practices with hands-on experience using enterprise-grade tools and methodologies.