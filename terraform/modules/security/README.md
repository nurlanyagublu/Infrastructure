# Security Module

This module creates and manages security resources including IAM roles, secrets management, encryption keys, and access policies for the infrastructure.

## Features

- **KMS Encryption**: Customer-managed KMS key with automatic rotation
- **IAM Roles**: Purpose-built roles for ECS tasks and CI/CD operations
- **Secrets Management**: AWS Secrets Manager for sensitive data
- **Parameter Store**: SSM Parameter Store for configuration management
- **CI/CD Integration**: GitHub Actions OIDC integration
- **Security Policies**: Least-privilege access policies

## Resources Created

### Encryption
- KMS customer-managed key with automatic rotation
- KMS alias for easy reference

### IAM Roles
- **ECS Task Execution Role**: For ECS to pull images and access secrets
- **ECS Task Role**: For application runtime permissions
- **CI/CD Role**: For GitHub Actions or other CI/CD systems

### Secrets & Configuration
- **Secrets Manager**: Encrypted storage for sensitive data (JWT secrets, API keys)
- **Parameter Store**: Configuration parameters (both plain and encrypted)
- **Auto-generated secrets**: JWT secret, API key, encryption key

### Security Policies
- Least-privilege policies for each role
- Resource-specific access controls
- KMS encryption/decryption permissions

## Usage

```hcl
module "security" {
  source = "./modules/security"

  project_name = "skillup-platform"
  environment  = "prod"
  aws_region   = "us-east-1"

  # Application configuration
  app_parameters = {
    app_name = {
      value  = "skillup-platform"
      secure = false
    }
    database_max_connections = {
      value  = "100"
      secure = false
    }
    redis_url = {
      value  = "redis://internal-cache:6379"
      secure = true
    }
  }

  # CI/CD Configuration
  enable_cicd_role         = true
  github_repository        = "your-username/skillup-platform"
  github_oidc_provider_arn = "arn:aws:iam::ACCOUNT:oidc-provider/token.actions.githubusercontent.com"

  # Optional: Provide your own secrets
  jwt_secret = var.jwt_secret  # Or leave empty for auto-generation
  api_key    = var.api_key     # Or leave empty for auto-generation

  additional_tags = {
    Team = "Platform"
    Cost = "Infrastructure"
  }
}
```

## Integration with Other Modules

### ECS Module Integration
```hcl
# In your ECS module, use the security module outputs
task_execution_role_arn = module.security.ecs_task_execution_role_arn
task_role_arn          = module.security.ecs_task_role_arn

# Reference secrets in task definitions
secrets = [
  {
    name      = "JWT_SECRET"
    valueFrom = "${module.security.app_secrets_arn}:jwt_secret::"
  },
  {
    name      = "API_KEY"
    valueFrom = "${module.security.app_secrets_arn}:api_key::"
  }
]
```

### Database Module Integration
```hcl
# Use the KMS key for database encryption
kms_key_id = module.security.kms_key_id
```

## Secrets Management

### Auto-generated Secrets
The module automatically generates secure secrets if not provided:
- **JWT Secret**: 64-character random string for JWT signing
- **API Key**: 32-character random string for API authentication
- **Encryption Key**: 32-character random string for application encryption

### Adding Custom Secrets
```hcl
additional_secrets = {
  "external-api-key" = {
    description = "Key for external service integration"
    value       = var.external_api_key
  }
  "webhook-secret" = {
    description = "Secret for webhook validation"
    value       = var.webhook_secret
  }
}
```

### Accessing Secrets in Applications
```bash
# In your application, retrieve secrets using AWS SDK
aws secretsmanager get-secret-value \
  --secret-id skillup-platform/prod/app-secrets \
  --query SecretString --output text | jq -r '.jwt_secret'
```

## CI/CD Integration

### GitHub Actions Setup
1. **Create OIDC Provider** (one-time setup per AWS account):
```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

2. **Configure GitHub Actions workflow**:
```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: us-east-1
      
      - name: Deploy to ECS
        run: |
          # Your deployment commands here
```

## Security Best Practices

### Implemented Security Features
- ✅ **Encryption at rest**: KMS encryption for secrets and parameters
- ✅ **Least privilege**: Minimal permissions for each role
- ✅ **Automatic rotation**: KMS key rotation enabled
- ✅ **Resource isolation**: Environment-specific resource naming
- ✅ **Audit trail**: CloudTrail integration for all API calls

### Recommended Additional Security
- Enable AWS Config for compliance monitoring
- Set up CloudWatch alarms for unusual access patterns
- Implement secret rotation for application secrets
- Use AWS Systems Manager Session Manager instead of SSH
- Enable VPC Flow Logs for network monitoring

## Outputs

Key outputs for integration with other modules:
- `ecs_task_execution_role_arn`: For ECS task definitions
- `ecs_task_role_arn`: For application runtime permissions
- `kms_key_arn`: For encrypting other resources
- `app_secrets_arn`: For referencing secrets in applications
- `cicd_role_arn`: For CI/CD pipeline configuration

## Troubleshooting

### Common Issues
1. **Secret access denied**: Check IAM role policies and KMS permissions
2. **CI/CD role assumption failed**: Verify GitHub OIDC provider setup
3. **Parameter Store access issues**: Ensure correct parameter naming pattern

### Debug Commands
```bash
# Test secret access
aws secretsmanager get-secret-value --secret-id PROJECT/ENV/app-secrets

# Check role assumptions
aws sts assume-role --role-arn ROLE_ARN --role-session-name test-session

# Verify KMS permissions
aws kms describe-key --key-id ALIAS_NAME
```
