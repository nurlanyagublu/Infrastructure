# Security Module Summary

## Overview
Comprehensive security module managing encryption, IAM roles, secrets, and access policies for the skillup platform infrastructure.

## Key Security Components

### 🔐 Encryption & Key Management
- **KMS Customer Key**: Encryption for all sensitive data
- **Automatic Rotation**: KMS key rotation enabled
- **Key Alias**: Easy reference via `alias/project-environment`

### 👤 IAM Roles & Policies
- **ECS Task Execution Role**: Container orchestration permissions
- **ECS Task Role**: Application runtime permissions
- **CI/CD Role**: GitHub Actions OIDC integration
- **Least Privilege**: Minimal required permissions only

### 🔒 Secrets Management
- **AWS Secrets Manager**: Encrypted storage for sensitive data
- **Auto-generated Secrets**: JWT secret, API key, encryption key
- **Custom Secrets**: Support for additional application secrets
- **KMS Encryption**: All secrets encrypted with customer-managed key

### ⚙️ Configuration Management
- **SSM Parameter Store**: Application configuration parameters
- **Secure Parameters**: Encrypted configuration using KMS
- **Environment Isolation**: Parameters namespaced by project/environment

## Security Features

### Access Control
```
ECS Tasks → Secrets Manager (via execution role)
ECS Tasks → Parameter Store (via task role)
CI/CD → ECS/ECR/S3 (via OIDC role)
All → KMS encryption/decryption
```

### Generated Resources
- **3 IAM Roles**: Task execution, task, CI/CD
- **4 IAM Policies**: Custom least-privilege policies
- **1 KMS Key**: Customer-managed encryption key
- **1 Secrets Manager**: Application secrets storage
- **N Parameters**: Configurable application settings

### GitHub Actions Integration
- **OIDC Provider**: Secure authentication without long-lived keys
- **Repository-specific**: Access limited to specified GitHub repo
- **Deployment Permissions**: ECS, ECR, S3 access for CI/CD

## Module Dependencies
- **Input**: Project name, environment, GitHub repository
- **Output**: Role ARNs, KMS key ARN, secrets ARN for other modules

## Security Best Practices Implemented
✅ **Encryption at Rest**: KMS encryption for all sensitive data  
✅ **Least Privilege**: Minimal IAM permissions  
✅ **Key Rotation**: Automatic KMS key rotation  
✅ **Environment Isolation**: Resource naming and access patterns  
✅ **CI/CD Security**: OIDC instead of access keys  

## Files Structure
```
security/
├── main.tf         # IAM roles, KMS key, secrets, parameters
├── variables.tf    # Configuration options and secrets
├── outputs.tf      # Role ARNs and resource identifiers
├── README.md       # Detailed documentation and examples
└── SUMMARY.md      # This overview file
```

## Integration Points
- **ECS Module**: Uses role ARNs for task definitions
- **Database Module**: Uses KMS key for encryption
- **Route53 Module**: Certificate ARN for HTTPS
- **CI/CD Pipeline**: Uses CI/CD role for deployments

## Critical Outputs
- `ecs_task_execution_role_arn`: For ECS service configuration
- `ecs_task_role_arn`: For application permissions
- `kms_key_arn`: For encrypting other AWS resources
- `app_secrets_arn`: For application secret references
- `cicd_role_arn`: For GitHub Actions configuration
