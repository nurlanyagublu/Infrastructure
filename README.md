# Infrastructure as Code Repository

This repository contains Terraform configurations for managing cloud infrastructure across multiple environments (dev, prod). The infrastructure is organized into reusable modules and environment-specific configurations.

## 🏗️ Repository Structure

```
Infrastructure/
├── .github/                    # GitHub workflows and templates
├── terraform/
│   ├── main.tf                # Root Terraform configuration
│   ├── cost-optimized-example.tf  # Cost optimization examples
│   ├── environment/           # Environment-specific configurations
│   │   ├── dev/              # Development environment
│   │   ├── prod/             # Production environment
│   │   └── README.md         # Environment setup guide
│   └── modules/              # Reusable Terraform modules
│       ├── database/         # RDS database module
│       ├── ECS/              # Elastic Container Service module
│       ├── networking/       # VPC, subnets, security groups
│       ├── route53/          # DNS and Route53 configuration
│       ├── s3-static-website/ # S3 static website hosting
│       └── security/         # Security-related resources
├── .gitignore                # Git ignore rules
└── README.md                 # This file
```

## 🚀 Quick Start

### Prerequisites

- **Terraform** >= 1.0
- **AWS CLI** configured with appropriate credentials
- **Git** for version control
- **Git LFS** for large file handling

### Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/nurlanyagublu/Infrastructure.git
   cd Infrastructure
   ```

2. **Initialize Terraform:**
   ```bash
   cd terraform/environment/dev  # or prod
   terraform init
   ```

3. **Plan your deployment:**
   ```bash
   terraform plan
   ```

4. **Apply the configuration:**
   ```bash
   terraform apply
   ```

## 🏢 Infrastructure Modules

### 🌐 Networking Module
- **VPC** with public and private subnets
- **Internet Gateway** and **NAT Gateway**
- **Security Groups** with predefined rules
- **Route Tables** for traffic management

### 🐳 ECS Module
- **ECS Cluster** for container orchestration
- **ECS Services** and **Task Definitions**
- **CloudWatch** logging and monitoring
- **Application Load Balancer** integration

### 🗄️ Database Module
- **RDS instances** with Multi-AZ support
- **Subnet Groups** for database placement
- **CloudWatch** monitoring and alarms
- **Backup and maintenance** configurations

### 🔒 Security Module
- **IAM roles** and policies
- **Security Groups** and **NACLs**
- **KMS keys** for encryption
- **CloudTrail** for audit logging

### 🌍 Route53 Module
- **DNS zones** and **record management**
- **Health checks** and **failover routing**
- **SSL certificate** integration

### 📦 S3 Static Website Module
- **S3 buckets** for static content
- **CloudFront** distribution
- **SSL certificate** configuration
- **Custom domain** support

## 🌍 Environments

### Development (dev)
- **Purpose**: Development and testing
- **Instance sizes**: Smaller, cost-optimized
- **Monitoring**: Basic CloudWatch metrics
- **Backup**: Daily snapshots

### Production (prod)
- **Purpose**: Production workloads
- **Instance sizes**: Production-grade
- **Monitoring**: Comprehensive monitoring and alerting
- **Backup**: Automated backups with retention

## 📋 Usage Guidelines

### Deploying to a New Environment

1. **Navigate to the environment directory:**
   ```bash
   cd terraform/environment/[dev|prod]
   ```

2. **Copy and customize terraform.tfvars:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your specific values
   ```

3. **Initialize and deploy:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

### Making Changes

1. **Create a new branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** to the Terraform files

3. **Test your changes:**
   ```bash
   terraform plan
   ```

4. **Commit and push:**
   ```bash
   git add .
   git commit -m "Description of changes"
   git push origin feature/your-feature-name
   ```

5. **Create a Pull Request** for review

## 🔧 Best Practices

### Code Organization
- Use **modules** for reusable components
- Keep **environment-specific** configurations separate
- Follow **consistent naming** conventions
- Add **comprehensive documentation**

### Security
- **Never commit** sensitive data (use terraform.tfvars files)
- Use **IAM roles** with least privilege
- Enable **encryption** at rest and in transit
- Regularly **rotate credentials**

### Cost Optimization
- Use **appropriate instance sizes** for each environment
- Implement **auto-scaling** where possible
- Set up **billing alerts** and **cost monitoring**
- Review **unused resources** regularly

## 📊 Monitoring and Alerting

- **CloudWatch** dashboards for key metrics
- **SNS notifications** for critical alerts
- **Cost and billing** alerts
- **Security** monitoring with CloudTrail

## 🛠️ Troubleshooting

### Common Issues

1. **Terraform state lock errors:**
   ```bash
   terraform force-unlock [LOCK_ID]
   ```

2. **Resource conflicts:**
   - Check for existing resources with same names
   - Review terraform state file

3. **Permission errors:**
   - Verify AWS credentials and permissions
   - Check IAM policies

### Getting Help

- Review module-specific README files
- Check Terraform documentation
- Contact the infrastructure team

## 🤝 Contributing

1. **Fork** the repository
2. **Create** a feature branch
3. **Make** your changes
4. **Test** thoroughly
5. **Submit** a pull request

## 📝 Documentation

- Each module contains its own README with specific documentation
- Check the `terraform/environment/README.md` for environment setup
- Review individual module documentation for detailed usage

## 🔒 Security Considerations

- All sensitive data should be stored in AWS Secrets Manager or Parameter Store
- Use terraform.tfvars files for environment-specific values (not committed to git)
- Regularly audit IAM permissions and security groups
- Keep Terraform and provider versions up to date

## 📞 Support

For questions or issues:
- Create an issue in this repository
- Contact the DevOps team
- Check the troubleshooting section above

---

**Note**: This infrastructure is managed using Infrastructure as Code principles. Always use Terraform for any infrastructure changes and avoid manual modifications through the AWS console.
