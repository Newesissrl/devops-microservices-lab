# Expenses Management System - Complete GitOps & DevSecOps Training Lab

A comprehensive microservices-based expense management application designed as an enterprise-grade GitOps and DevSecOps training platform. This solution demonstrates modern containerization, orchestration, security integration, secrets management, and automated deployment practices using AWS-native services.

## Architecture Overview

This lab simulates a real-world microservices architecture with multiple technology stacks:

- **Frontend** (React) - B2B web application with authentication and expense management
- **Backend** (Node.js/Express) - REST API service with JWT authentication and message publishing
- **Processor** (Python) - Integration service simulating third-party data processing
- **Lake Publisher** (C#) - Data lake integration service for analytics workflows
- **Database** (MongoDB) - Document-based data persistence
- **Message Queue** (RabbitMQ) - Asynchronous communication between services

## Training Objectives

Students will master enterprise-grade DevOps practices:

### **Core DevOps Skills**
1. **Containerization**: Multi-stage Dockerfiles with security hardening and test execution
2. **Local Development**: Docker Compose orchestration with development and production configurations
3. **Infrastructure as Code**: Terraform modules for AWS ECS, VPC, RDS with environment-specific deployments
4. **Container Orchestration**: Both Kubernetes (Helm charts) and AWS ECS deployment strategies

### **GitOps Implementation**
5. **Git-Driven Deployments**: Automated deployments triggered by Git events with approval gates
6. **Declarative Configuration**: All infrastructure and application config stored in Git
7. **Environment Promotion**: Dev → Staging → Production workflow with validation gates
8. **Drift Detection**: Automated infrastructure drift monitoring and remediation

### **DevSecOps Integration**
9. **Security Scanning**: SAST (CodeQL), container scanning (Trivy), infrastructure security (TFLint, tfsec, Checkov)
10. **Secrets Management**: SOPS encryption with AWS KMS and OIDC authentication
11. **Compliance**: Automated policy validation and security best practices enforcement
12. **Zero-Trust Security**: No long-lived credentials, encrypted secrets, least privilege access

### **Advanced Deployment Strategies**
13. **Blue-Green Deployments**: Zero-downtime deployments with instant rollback
14. **Canary Deployments**: Gradual traffic shifting with automated monitoring
15. **Infrastructure Monitoring**: CloudWatch dashboards, alerting, and observability as code

## Prerequisites

Install the following on your system:

- **Node.js** (v16+) and npm
- **Python** (v3.8+) and pip
- **.NET 9.0 SDK** or later
- **MongoDB** (running on default port 27017)
- **RabbitMQ** (running on default port 5672)

## Quick Start

### 1. Backend API
```bash
cd packages/backend
npm install
npm start
```
Runs on: http://localhost:3000

### 2. Frontend Application
```bash
cd packages/frontend
npm install
npm start
```
Runs on: http://localhost:3030

### 3. Message Processor
```bash
cd packages/processor
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python processor.py
```

### 4. Lake Publisher (Optional)
```bash
cd packages/lakepublisher
dotnet restore
dotnet run
```

## Features

### Frontend
- User authentication with username/password login
- Create, view, edit, delete expenses with exported status
- File attachment upload/download
- Modal-based expense details with inline editing
- Export status tracking and display
- Responsive design

### Backend
- JWT-based authentication with configurable users
- RESTful API with full CRUD operations
- File upload and secure download endpoints
- RabbitMQ message publishing for all operations
- MongoDB integration with Mongoose ODM
- Exported field management for data lake integration

### Processor
- Consumes RabbitMQ messages from backend
- Saves all expense events to JSON files
- Configurable output directory
- Graceful error handling

### Lake Publisher
- Token-based API authentication for secure access
- Exports approved expenses to Apache Parquet format
- Hierarchical date-based folder structure (yyyy/mm/dd)
- Updates exported status to prevent duplicates
- Configurable filtering and output paths

## Configuration

Each component uses environment variables:

- **Backend**: `packages/backend/.env`
- **Processor**: `packages/processor/.env`
- **Lake Publisher**: `packages/lakepublisher/.env`
- **Frontend**: Runtime configuration via `public/config.js`

## Training Phases

### **Phase 1: Foundation (Containerization & Local Development)**
- Multi-stage Dockerfiles with test execution and security hardening
- Docker Compose orchestration with development and production configurations
- Container security best practices and optimization

### **Phase 2: Infrastructure as Code**
- Terraform modules for AWS infrastructure (VPC, ECS, RDS, ALB)
- Environment-specific configurations (dev/staging/prod)
- SOPS integration for secrets management
- AWS OIDC authentication setup

### **Phase 3: GitOps Implementation**
- Git-driven deployment workflows with approval gates
- Infrastructure drift detection and automated remediation
- Environment promotion strategies with validation
- Configuration management with Parameter Store integration

### **Phase 4: DevSecOps Integration**
- Comprehensive security scanning pipeline (SAST, container, infrastructure)
- Secrets encryption and management with SOPS and AWS KMS
- Policy-as-code validation with Checkov and custom rules
- Zero-trust security implementation

### **Phase 5: Advanced Deployment Strategies**
- Blue-green deployments with ECS and ALB
- Canary deployments with traffic shifting and monitoring
- Automated rollback on health check failures
- Production deployment with multiple approval gates

### **Phase 6: Observability & Monitoring**
- CloudWatch dashboards and alerting as code
- Application and infrastructure monitoring
- Log aggregation and analysis
- Performance monitoring and optimization

## Development Workflow

### **Local Development**
```bash
# Start all services with development configuration
docker-compose up --build

# Access application
open http://localhost:3030
```

### **GitOps Deployment Workflow**
```bash
# Development (automatic)
git push origin develop  # Triggers automatic deployment to dev

# Staging (manual approval)
git push origin main     # Triggers staging deployment with approval

# Production (strict approval)
# Use GitHub Actions manual trigger with staging-validated image tag
```

## Message Flow

```
Frontend → Backend API → MongoDB
                    ↓
                RabbitMQ → Processor → JSON Files
                    ↓
            Lake Publisher → Parquet Files
```

## Project Structure

```
packages/
├── backend/          # Node.js API server
├── frontend/         # React application
├── processor/        # Python message consumer
└── lakepublisher/    # C# data lake publisher
```

## Service Simulation Details

- **Frontend + Backend**: Simulates a B2B expense management platform
- **Python Processor**: Simulates integration with external audit systems (saves to filesystem but could send to third-party APIs)
- **C# Lake Publisher**: Simulates data lake integration for analytics and reporting workflows

## Repository Structure

```
├── README.md                    # This comprehensive guide
├── GitOps.md                   # GitOps principles and implementation
├── DevSecOps.md               # Security integration documentation
├── SECRETS-MANAGEMENT.md      # SOPS and AWS OIDC guide
├── .sops.yaml                 # SOPS encryption configuration
│
├── packages/                  # Microservices source code
│   ├── backend/              # Node.js API with JWT auth
│   ├── frontend/             # React SPA with runtime config
│   ├── processor/            # Python RabbitMQ consumer
│   └── lakepublisher/        # C# data export service
│
├── devops/
│   ├── terraform/            # Infrastructure as Code
│   │   ├── modules/         # Reusable Terraform modules
│   │   ├── environments/    # Environment-specific configs
│   │   └── backend/         # Backend configuration (SOPS encrypted)
│   ├── ecs/                 # ECS task and service definitions
│   ├── kubernetes/          # Kubernetes manifests
│   ├── helm/               # Helm charts with encrypted secrets
│   └── monitoring/         # CloudWatch dashboards as code
│
├── config/environments/      # Application configuration
│   ├── dev/                # Development settings
│   ├── staging/            # Staging settings
│   └── prod/              # Production settings
│
├── .github/workflows/        # GitOps automation
│   ├── security.yml         # Security scanning pipeline
│   ├── build-and-push.yml   # Container image building
│   ├── infrastructure.yml   # Terraform automation
│   ├── deploy-dev.yml      # Development deployment
│   ├── deploy-staging.yml  # Staging deployment
│   └── deploy-prod.yml     # Production deployment
│
└── docker-compose.yml       # Local development orchestration
```

## Key Features Implemented

### **🔐 Security-First Approach**
- **SOPS Encryption**: All secrets encrypted with AWS KMS
- **OIDC Authentication**: No long-lived AWS credentials
- **Multi-Layer Scanning**: SAST, container, and infrastructure security
- **Policy Enforcement**: Automated compliance validation

### **🚀 GitOps Methodology**
- **Declarative Configuration**: Everything defined as code in Git
- **Automated Deployments**: Git push triggers deployment pipelines
- **Approval Gates**: Environment-specific approval requirements
- **Drift Detection**: Continuous infrastructure monitoring

### **🏗️ Enterprise Architecture**
- **Multi-Environment**: Dev, Staging, Production with isolation
- **Scalable Infrastructure**: Auto-scaling ECS services with ALB
- **High Availability**: Multi-AZ deployment with health checks
- **Disaster Recovery**: Automated backup and rollback procedures

### **📊 Comprehensive Monitoring**
- **Infrastructure Metrics**: CPU, memory, network, storage monitoring
- **Application Metrics**: Response time, error rate, throughput
- **Business Metrics**: User actions, feature usage, KPIs
- **Security Monitoring**: Vulnerability tracking and compliance reporting

## Getting Started

### **Prerequisites**
- AWS Account with appropriate permissions
- GitHub repository with Actions enabled
- Docker and Docker Compose
- Terraform >= 1.6.0
- SOPS for secrets management
- AWS CLI configured

### **Quick Start**
1. **Clone the repository**
2. **Review documentation**: Start with `GitOps.md` and `DevSecOps.md`
3. **Setup AWS OIDC**: Follow `SECRETS-MANAGEMENT.md` guide
4. **Configure secrets**: Encrypt sensitive values with SOPS
5. **Deploy infrastructure**: Use Terraform workflows
6. **Deploy applications**: Use GitOps deployment workflows

### **Training Path**
1. **Local Development**: Start with Docker Compose
2. **Infrastructure**: Deploy AWS resources with Terraform
3. **Security**: Implement SOPS and security scanning
4. **GitOps**: Set up automated deployment pipelines
5. **Production**: Deploy with approval gates and monitoring

## Documentation

- **[GitOps.md](GitOps.md)**: Complete GitOps implementation guide
- **[DevSecOps.md](DevSecOps.md)**: Security integration and best practices
- **[SECRETS-MANAGEMENT.md](SECRETS-MANAGEMENT.md)**: SOPS and AWS OIDC setup
- **Package READMEs**: Individual service documentation in `packages/*/README.md`

This repository serves as a comprehensive training platform for modern DevOps, GitOps, and DevSecOps practices, providing hands-on experience with enterprise-grade tools and methodologies.