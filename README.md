# CleanPro - Modern Cloud-Native Cleaning Service Platform

[![CI/CD Pipeline](https://github.com/senopaul/CleanPro/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/senopaul/CleanPro/actions/workflows/ci-cd.yml)
[![Terraform](https://img.shields.io/badge/Infrastructure-Terraform-623CE4)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/Cloud-AWS-FF9900)](https://aws.amazon.com/)
[![Python](https://img.shields.io/badge/Language-Python_3.11-3776AB)](https://www.python.org/)
[![Flask](https://img.shields.io/badge/Framework-Flask-000000)](https://flask.palletsprojects.com/)
[![Docker](https://img.shields.io/badge/Container-Docker-2496ED)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Security](https://img.shields.io/badge/Security-Bandit-yellow)](https://github.com/PyCQA/bandit)

CleanPro is a cloud-native web application for a cleaning service company based in Tel Aviv, Israel. This project demonstrates modern DevOps practices with infrastructure as code, containerization, CI/CD automation, and secure deployment practices.

## 📋 Table of Contents

- [Architecture Overview](#-architecture-overview)
- [Infrastructure Details](#-infrastructure-details)
- [Local Development Setup](#-local-development-setup)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Development Workflow](#-development-workflow)
- [Production Deployment](#-production-deployment)
- [Security Practices](#-security-practices)
- [Contributing](#-contributing)
- [Contact](#-contact)

## 🏗 Architecture Overview

CleanPro follows a modern cloud-native architecture designed for scalability, reliability, and security.

```
┌───────────────────────────────────────────────────────────────────────────┐
│                                  AWS Cloud                                 │
│                                                                           │
│   ┌─────────────┐      ┌─────────────┐      ┌─────────────┐               │
│   │  Application│      │     ECS     │      │   RDS DB    │               │
│   │ Load Balancer│─────▶   Cluster   │─────▶  (PostgreSQL)│               │
│   └─────────────┘      └─────────────┘      └─────────────┘               │
│          ▲                    │                                           │
│          │                    │                                           │
│          │                    ▼                                           │
│   ┌─────────────┐      ┌─────────────┐      ┌─────────────┐               │
│   │CloudFront CDN│      │   CloudWatch│      │   S3 Bucket │               │
│   │  (optional)  │      │  Monitoring │      │  (Storage)  │               │
│   └─────────────┘      └─────────────┘      └─────────────┘               │
│                                                                           │
└───────────────────────────────────────────────────────────────────────────┘
```

The architecture is designed for the Israeli market with the following considerations:
- **Regional Proximity**: Infrastructure deployed in eu-west-1 (Ireland) for lowest latency to Israel
- **Hebrew Language Support**: Application supports Hebrew RTL text rendering
- **Compliance**: Infrastructure designed with Israeli privacy regulations in mind

## 🔧 Infrastructure Details

### AWS Resources

The entire infrastructure is defined as code using Terraform:

- **VPC & Networking**:
  - Custom VPC with public and private subnets across 3 availability zones
  - Internet Gateway and NAT Gateways for secure outbound connections
  - Security groups with principle of least privilege

- **Compute**:
  - ECS Fargate for containerized applications
  - Auto-scaling based on CPU and memory utilization
  - Serverless deployment for cost optimization

- **Database**:
  - RDS PostgreSQL for structured data
  - Multi-AZ deployment for high availability (production only)
  - Automated backups and point-in-time recovery

- **Security & Monitoring**:
  - AWS CloudWatch for logging and monitoring
  - CloudTrail for audit logging
  - VPC Flow Logs for network monitoring

### Environment Separation

The infrastructure supports multiple environments:
- **Development**: For active development and testing
- **Staging**: For pre-production validation
- **Production**: For live customer-facing services

## 💻 Local Development Setup

### Prerequisites

- Docker and Docker Compose
- Python 3.11+
- AWS CLI (configured)
- Terraform (optional, for infrastructure work)

### Quick Start

1. **Clone the repository**:
   ```bash
   git clone https://github.com/senopaul/CleanPro.git
   cd CleanPro
   ```

2. **Create environment file**:
   ```bash
   cp .env.example .env
   # Edit .env with your local settings
   ```

3. **Start local development environment**:
   ```bash
   docker-compose up -d
   ```

4. **Access the application**:
   - Web: http://localhost:5000
   - Database admin: http://localhost:8080 (Adminer)

### Local Development Commands

- **Run tests**:
  ```bash
  docker-compose exec web pytest
  ```

- **Run linting**:
  ```bash
  docker-compose exec web flake8
  docker-compose exec web black .
  ```

- **Database migrations**:
  ```bash
  docker-compose exec web flask db migrate -m "Migration message"
  docker-compose exec web flask db upgrade
  ```

## 🚀 CI/CD Pipeline

Our CI/CD pipeline automates testing, security scanning, and deployment across environments.

```
┌───────────┐     ┌───────────┐     ┌───────────┐     ┌───────────┐
│   Test    │────▶│  Security │────▶│   Build   │────▶│  Deploy   │
│  & Lint   │     │   Scan    │     │ Container │     │   Dev     │
└───────────┘     └───────────┘     └───────────┘     └─────┬─────┘
                                                            │
                                                            ▼
                                                     ┌───────────┐
                                                     │  Deploy   │
                                                     │  Staging  │
                                                     └─────┬─────┘
                                                            │
                                                            ▼
                                                     ┌───────────┐
                                                     │  Deploy   │
                                                     │ Production│
                                                     └───────────┘
```

### Pipeline Features

- **Automated Testing**: Unit and integration tests
- **Code Quality**: Linting with flake8 and black
- **Security Scanning**: Bandit for code security and Safety for dependency vulnerabilities
- **Infrastructure Validation**: Terraform validation and planning
- **Container Building**: Multi-stage Docker builds for minimal image size
- **Progressive Deployment**: Development → Staging → Production

## 📋 Development Workflow

### Branch Strategy

- **main**: Production-ready code
- **develop**: Integration branch for feature work
- **feature/***:  Individual feature branches

### Development Process

1. Create a feature branch from develop
   ```bash
   git checkout develop
   git pull
   git checkout -b feature/new-feature
   ```

2. Make changes and commit
   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

3. Push and create a pull request to develop
   ```bash
   git push -u origin feature/new-feature
   # Create PR through GitHub interface
   ```

4. Automated checks run on the PR
   - Tests must pass
   - Code must be properly formatted
   - Security scans must pass
   - At least one approval required

5. After merge to develop, changes are automatically deployed to development environment

6. Releases to staging and production are managed through GitHub Releases

## 🌍 Production Deployment

### Deployment Process

1. Create a release tag
   ```bash
   git checkout develop
   git pull
   git checkout -b release/v1.0.0
   # Make any release-specific changes
   git commit -m "chore: prepare v1.0.0 release"
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. Create a GitHub Release
   - Go to GitHub Releases
   - Create a new release using the tag
   - Add release notes
   - Publish release

3. Manual approval for production deployment
   - CI/CD pipeline will deploy to staging automatically
   - Production deployment requires manual approval in GitHub

### Rollback Procedure

In case of issues, rollback can be performed:

1. Identify the previous stable version
2. Trigger a deployment of that version via GitHub workflow dispatch
3. Verify the rollback resolves the issue

## 🔒 Security Practices

- **Least Privilege**: IAM roles with minimal permissions
- **Secrets Management**: AWS Secrets Manager for credentials
- **Dependency Scanning**: Regular checks for vulnerable dependencies
- **Container Scanning**: Image scanning before deployment
- **Infrastructure Security**: Security groups limit access
- **Compliance**: GDPR-aligned data handling

## 👥 Contributing

We welcome contributions! Please follow these steps:

1. Check the issues page for open tasks
2. Fork the repository
3. Create a feature branch
4. Make your changes
5. Run tests and linting locally
6. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## 📞 Contact

For questions or collaboration opportunities:

- **Creator**: Seno Paul
- **GitHub**: [@senopaul](https://github.com/senopaul)
- **Location**: Israel

---

© 2025 CleanPro - Modern DevOps Showcase Project

