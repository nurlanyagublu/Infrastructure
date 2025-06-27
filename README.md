# RealWorld Full-Stack Application with Infrastructure as Code

This repository contains a complete full-stack implementation of the [RealWorld](https://github.com/gothinkster/realworld) application, including a Vue3 frontend, Flask API backend, and comprehensive AWS infrastructure managed through Terraform.

## 🏗️ Repository Structure

```
Web_App/
├── README.md                           # This file
├── realworld-flask/                    # Backend API (Flask + PostgreSQL)
│   ├── realworld/                      # Main application code
│   │   ├── api/                        # API endpoints
│   │   ├── app.py                      # Flask application
│   │   └── config/                     # Configuration files
│   ├── alembic/                        # Database migrations
│   ├── scripts/                        # Deployment and utility scripts
│   ├── tests/                          # API tests
│   ├── Dockerfile                      # Container configuration
│   ├── pyproject.toml                  # Python dependencies
│   ├── README.md                       # Backend documentation
│   └── TERRAFORM_DEPLOYMENT.md         # Backend deployment guide
├── vue3-realworld-example-app/         # Frontend (Vue3 + TypeScript)
│   ├── src/                            # Source code
│   │   ├── components/                 # Vue components
│   │   ├── pages/                      # Page components
│   │   ├── services/                   # API services
│   │   ├── store/                      # Pinia state management
│   │   └── types/                      # TypeScript types
│   ├── cypress/                        # E2E tests
│   ├── dist/                           # Built application
│   ├── scripts/                        # Build and deployment scripts
│   ├── Dockerfile                      # Container configuration
│   ├── package.json                    # Node.js dependencies
│   ├── README.md                       # Frontend documentation
│   ├── DEPLOYMENT_GUIDE.md             # Frontend deployment guide
│   └── FRONTEND_INSTRUCTIONS.md        # Development instructions
└── terraform/                          # Infrastructure as Code
    ├── main.tf                         # Root Terraform configuration
    ├── cost-optimized-example.tf       # Cost optimization examples
    ├── environment/                    # Environment-specific configs
    │   ├── dev/                        # Development environment
    │   ├── prod/                       # Production environment
    │   └── README.md                   # Environment setup guide
    └── modules/                        # Reusable Terraform modules
        ├── database/                   # RDS PostgreSQL module
        ├── ECS/                        # Container orchestration
        ├── networking/                 # VPC, subnets, security
        ├── route53/                    # DNS and SSL certificates
        ├── s3-static-website/          # Static website hosting
        └── security/                   # IAM, KMS, security policies
```

## 🚀 Architecture Overview

```
Internet → Route 53 → CloudFront → S3 (Vue3 Frontend)
                          ↓
Internet → Route 53 → ALB → ECS Fargate (Flask API) → RDS PostgreSQL
                          ↓
                     CloudWatch (Monitoring & Logging)
```

### Components

- **Frontend**: Vue3 + TypeScript + Pinia + Vite
- **Backend**: Flask + SQLAlchemy + PostgreSQL + Alembic
- **Infrastructure**: AWS ECS Fargate + RDS + S3 + CloudFront + Route53
- **Containerization**: Docker for both frontend and backend
- **CI/CD**: GitHub Actions with OIDC authentication
- **Monitoring**: CloudWatch with comprehensive logging

## 🌟 Features

### Application Features
- ✅ **Authentication & Authorization** (JWT tokens)
- ✅ **CRUD Operations** (Articles, Comments, User profiles)
- ✅ **Real-time Updates** (Following users, favoriting articles)
- ✅ **Responsive Design** (Mobile-first approach)
- ✅ **Type Safety** (Full TypeScript implementation)
- ✅ **State Management** (Pinia stores)
- ✅ **E2E Testing** (Cypress test suite)

### Infrastructure Features
- ✅ **Multi-Environment Support** (Dev/Prod with different configurations)
- ✅ **Auto-Scaling** (ECS services with target tracking)
- ✅ **High Availability** (Multi-AZ deployment in production)
- ✅ **SSL/TLS Termination** (ACM certificates with automatic renewal)
- ✅ **Content Distribution** (CloudFront CDN for global performance)
- ✅ **Security** (VPC isolation, security groups, IAM roles)
- ✅ **Monitoring** (CloudWatch dashboards, alarms, and logging)
- ✅ **Cost Optimization** (Environment-specific resource sizing)

## 🚀 Quick Start

### Prerequisites

- **AWS CLI** configured with appropriate credentials
- **Terraform** >= 1.0
- **Docker** for local development
- **Node.js** >= 18 (for frontend development)
- **Python** >= 3.11 (for backend development)

### 1. Clone and Setup

```bash
git clone <repository-url>
cd Web_App
```

### 2. Infrastructure Deployment

Deploy the infrastructure first (choose dev or prod):

```bash
cd terraform/environment/dev  # or prod
terraform init
terraform plan
terraform apply
```

For detailed infrastructure setup, see: [`terraform/environment/README.md`](terraform/environment/README.md)

### 3. Backend Development

```bash
cd realworld-flask

# Setup Python environment
poetry install

# Run database migrations
alembic upgrade head

# Start the development server
poetry run python -m realworld.app
```

For detailed backend setup, see: [`realworld-flask/README.md`](realworld-flask/README.md)

### 4. Frontend Development

```bash
cd vue3-realworld-example-app

# Install dependencies
npm install

# Start development server
npm run dev
```

For detailed frontend setup, see: [`vue3-realworld-example-app/README.md`](vue3-realworld-example-app/README.md)

## 🔧 Development Workflow

### Local Development

1. **Start the backend**:
   ```bash
   cd realworld-flask
   poetry run python -m realworld.app
   ```

2. **Start the frontend**:
   ```bash
   cd vue3-realworld-example-app
   npm run dev
   ```

3. **Run tests**:
   ```bash
   # Backend tests
   cd realworld-flask && poetry run pytest

   # Frontend tests
   cd vue3-realworld-example-app && npm run test

   # E2E tests
   cd vue3-realworld-example-app && npm run cypress:run
   ```

### Deployment

1. **Build and push containers**:
   ```bash
   # Backend
   cd realworld-flask && docker build -t your-registry/realworld-api .

   # Frontend
   cd vue3-realworld-example-app && npm run build
   ```

2. **Deploy via CI/CD** (GitHub Actions automatically handles deployment)

3. **Manual deployment** (if needed):
   ```bash
   cd terraform/environment/prod
   terraform apply
   ```

## 🌍 Environment Configuration

### Development Environment
- **Cost-optimized**: Small instance sizes, single AZ
- **Domains**: `dev-app.yourdomain.com`, `dev-api.yourdomain.com`
- **Database**: db.t3.micro with 1-day backup retention
- **Monitoring**: Basic CloudWatch metrics

### Production Environment
- **High availability**: Multi-AZ deployment, auto-scaling
- **Domains**: `app.yourdomain.com`, `api.yourdomain.com`
- **Database**: db.t3.small with 30-day backup retention
- **Monitoring**: Comprehensive monitoring and alerting

## 📋 Deployment Guides

- **Infrastructure Setup**: [`terraform/environment/README.md`](terraform/environment/README.md)
- **Backend Deployment**: [`realworld-flask/TERRAFORM_DEPLOYMENT.md`](realworld-flask/TERRAFORM_DEPLOYMENT.md)
- **Frontend Deployment**: [`vue3-realworld-example-app/DEPLOYMENT_GUIDE.md`](vue3-realworld-example-app/DEPLOYMENT_GUIDE.md)

## 🔒 Security Features

- **Network Isolation**: VPC with private subnets for database and application
- **Encryption**: KMS encryption for all data at rest and in transit
- **Access Control**: IAM roles with least-privilege principles
- **Secrets Management**: AWS Secrets Manager for sensitive data
- **Security Groups**: Restrictive firewall rules
- **SSL/TLS**: End-to-end encryption with ACM certificates

## 📊 Monitoring and Observability

- **Application Metrics**: Custom CloudWatch metrics
- **Infrastructure Monitoring**: ECS, RDS, and ALB metrics
- **Logging**: Centralized logging with CloudWatch Logs
- **Alerting**: SNS notifications for critical events
- **Dashboards**: Pre-configured CloudWatch dashboards

## 💰 Cost Optimization

- **Environment-specific sizing**: Different resource allocation per environment
- **Auto-scaling**: Scale resources based on demand
- **Cost monitoring**: Billing alerts and cost tracking
- **Resource optimization**: Regular review of unused resources

## 🧪 Testing

### Backend Testing
- **Unit Tests**: pytest with comprehensive coverage
- **Integration Tests**: API endpoint testing
- **Database Tests**: Alembic migration testing

### Frontend Testing
- **Unit Tests**: Vitest for component testing
- **E2E Tests**: Cypress for full application flow
- **Type Checking**: TypeScript for compile-time verification

### Infrastructure Testing
- **Terraform Validation**: syntax and plan validation
- **Security Scanning**: Infrastructure security analysis
- **Cost Estimation**: Terraform cost analysis

## 🤝 Contributing

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add some amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Development Guidelines

- Follow existing code style and conventions
- Add tests for new features
- Update documentation as needed
- Test changes in development environment first

## 📞 Support and Documentation

### Getting Help
- **Issues**: Create GitHub issues for bugs or feature requests
- **Discussions**: Use GitHub Discussions for questions
- **Documentation**: Check component-specific README files

### Documentation Index
- [Infrastructure Guide](terraform/environment/README.md)
- [Backend API Documentation](realworld-flask/README.md)
- [Frontend Development Guide](vue3-realworld-example-app/README.md)
- [Deployment Guides](vue3-realworld-example-app/DEPLOYMENT_GUIDE.md)

## 📄 License

This project is licensed under the MIT License - see the individual component LICENSE files for details.

## 🙏 Acknowledgments

- [RealWorld](https://github.com/gothinkster/realworld) - The specification and community
- [Vue3](https://v3.vuejs.org/) - The progressive JavaScript framework
- [Flask](https://flask.palletsprojects.com/) - The Python web framework
- [Terraform](https://www.terraform.io/) - Infrastructure as Code tool

---

**Note**: This is a production-ready implementation following best practices for security, scalability, and maintainability. All infrastructure changes should be made through Terraform to maintain consistency and version control.
