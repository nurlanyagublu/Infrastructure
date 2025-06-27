# Environment Configurations

This directory contains environment-specific Terraform configurations for deploying the complete infrastructure stack.

## Directory Structure

```
environment/
├── dev/                    # Development environment
│   ├── main.tf            # Main configuration with all modules
│   ├── variables.tf       # Variable definitions
│   ├── terraform.tfvars   # Development-specific values
│   └── outputs.tf         # Outputs for dev environment
├── prod/                   # Production environment
│   ├── main.tf            # Main configuration with all modules
│   ├── variables.tf       # Variable definitions
│   ├── terraform.tfvars   # Production-specific values
│   └── outputs.tf         # Outputs for prod environment
└── README.md              # This file
```

## Environment Differences

### Development Environment
- **Cost-optimized**: Uses smaller instance sizes and minimal resources
- **Simplified**: Single AZ deployment, basic monitoring
- **Relaxed security**: No deletion protection, shorter backup retention
- **VPC CIDR**: 10.0.0.0/16
- **Database**: db.t3.micro with 1-day backup retention
- **ECS**: 1-2 instances with lower CPU/memory
- **Domain**: dev-app.yourdomain.com, dev-api.yourdomain.com

### Production Environment
- **High availability**: Multi-AZ deployment across 3 availability zones
- **Performance**: Larger instance sizes, enhanced monitoring
- **Security**: Deletion protection, 30-day backup retention
- **VPC CIDR**: 10.1.0.0/16 (different from dev)
- **Database**: db.t3.small with comprehensive monitoring
- **ECS**: 2-10 instances with auto-scaling
- **Domain**: app.yourdomain.com, api.yourdomain.com

## Modules Included

Each environment includes all infrastructure modules:

1. **Security Module** - KMS encryption, IAM roles, secrets management
2. **Networking Module** - VPC, subnets, security groups
3. **Database Module** - RDS PostgreSQL with backups
4. **ECS Module** - Container orchestration with load balancer
5. **S3 Static Website Module** - Static content hosting
6. **Route 53 Module** - DNS and SSL certificates

## Usage

### Prerequisites

1. **AWS CLI configured** with appropriate credentials
2. **Terraform installed** (version >= 1.0)
3. **Domain configured** in Route 53 (update in terraform.tfvars)

### Environment Variables

Set the database password as an environment variable:

```bash
export TF_VAR_db_password="your-secure-password"
```

### Deployment Steps

#### Deploy Development Environment

```bash
# Navigate to dev environment
cd environment/dev

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

#### Deploy Production Environment

```bash
# Navigate to prod environment
cd environment/prod

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

### Configuration Customization

Before deploying, update the following in `terraform.tfvars`:

1. **Domain Configuration**:
   ```hcl
   domain_name = "yourdomain.com"
   ```

2. **GitHub Repository** (for CI/CD):
   ```hcl
   github_repository = "yourusername/yourrepo"
   ```

3. **Application Image**:
   ```hcl
   app_image = "your-registry/your-app:tag"
   ```

4. **Project Name**:
   ```hcl
   project_name = "your-project-name"
   ```

## Security Considerations

### Secrets Management
- Database passwords are managed via environment variables
- Application secrets are stored in AWS Secrets Manager
- KMS encryption is enabled for all storage

### Network Security
- Private subnets for database and application
- Security groups with least-privilege access
- VPC endpoints for AWS services (planned)

### CI/CD Integration
- GitHub OIDC provider for secure deployments
- IAM roles with minimal required permissions
- Secrets available to GitHub Actions

## Monitoring and Logging

### Development
- Basic CloudWatch monitoring
- Error logs only for cost optimization
- No enhanced monitoring

### Production
- Enhanced CloudWatch monitoring
- All log types exported
- Performance Insights enabled
- 30-day log retention

## Cost Optimization

### Development Environment
- Single AZ deployment
- Minimal instance sizes
- Basic monitoring
- Short backup retention
- No CloudFront distribution

### Production Environment
- Multi-AZ for high availability
- Appropriately sized instances
- Comprehensive monitoring
- CloudFront for performance
- 30-day backup retention

## Outputs

After deployment, each environment provides:

- **Network IDs**: VPC, subnet, and security group identifiers
- **Database**: Endpoint and connection information
- **Load Balancer**: DNS name and zone ID
- **Domains**: Application and API URLs
- **Security**: IAM role ARNs and KMS key ARN

## Troubleshooting

### Common Issues

1. **Domain not found**: Ensure domain is configured in Route 53
2. **Certificate validation**: DNS validation can take 5-10 minutes
3. **ECS deployment**: Container may take a few minutes to start
4. **Database connection**: Ensure security groups allow connection

### Useful Commands

```bash
# Check Terraform state
terraform show

# Get outputs
terraform output

# Destroy environment (be careful!)
terraform destroy
```

## Next Steps

After deploying environments:

1. **Set up CI/CD pipeline** using the provided IAM roles
2. **Configure application secrets** in AWS Secrets Manager
3. **Set up monitoring alerts** in CloudWatch
4. **Configure backup policies** for production data
5. **Implement blue-green deployment** strategy

## Support

For issues or questions:
1. Check the module documentation in `../modules/`
2. Review AWS CloudWatch logs for runtime issues
3. Use `terraform plan` to preview changes before applying
