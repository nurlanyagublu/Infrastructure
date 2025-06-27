# Networking Module

This module creates a production-ready VPC with multi-tier architecture for the realworld application.

## Architecture

```
VPC (10.0.0.0/16)
├── Public Subnets (10.0.1.0/24, 10.0.2.0/24)
│   ├── Application Load Balancer
│   ├── NAT Gateways
│   └── Bastion Host (optional)
│
├── Private App Subnets (10.0.11.0/24, 10.0.12.0/24)
│   └── ECS Fargate Tasks (Flask API)
│
└── Private DB Subnets (10.0.21.0/24, 10.0.22.0/24)
    └── RDS PostgreSQL
```

## Features

- **Multi-AZ deployment** for high availability
- **Three-tier architecture** (public, app, database)
- **NAT Gateways** for private subnet internet access
- **VPC Endpoints** for cost optimization and security
- **Security Groups** with least privilege access
- **Configurable** for different environments

## Security Groups

1. **ALB Security Group**: HTTP/HTTPS from internet
2. **ECS Security Group**: HTTP from ALB only
3. **RDS Security Group**: PostgreSQL from ECS only
4. **VPC Endpoints Security Group**: HTTPS from private subnets
5. **Bastion Security Group**: SSH from specified IP ranges (optional)

## Cost Optimization Features

- **Optional NAT Gateways**: Can be disabled for development
- **Single NAT Gateway option**: For cost savings (not recommended for production)
- **VPC Endpoints**: Reduce data transfer costs
- **Gateway endpoints**: S3 access without internet charges

## Usage

```hcl
module "networking" {
  source = "./modules/networking"

  project_name = "realworld"
  environment  = "dev"

  # VPC Configuration
  vpc_cidr                   = "10.0.0.0/16"
  public_subnet_cidrs        = ["10.0.1.0/24", "10.0.2.0/24"]
  private_app_subnet_cidrs   = ["10.0.11.0/24", "10.0.12.0/24"]
  private_db_subnet_cidrs    = ["10.0.21.0/24", "10.0.22.0/24"]

  # Feature toggles
  enable_nat_gateway    = true
  enable_vpc_endpoints  = true
  enable_bastion        = false

  # Application configuration
  app_port = 5000

  common_tags = {
    Project     = "realworld"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
```

## Environment-Specific Configurations

### Development
```hcl
enable_nat_gateway    = true
enable_vpc_endpoints  = false
enable_bastion        = false
single_nat_gateway    = true  # Cost optimization
```

### Production
```hcl
enable_nat_gateway    = true
enable_vpc_endpoints  = true
enable_bastion        = true
single_nat_gateway    = false  # High availability
```

## Outputs

The module provides comprehensive outputs for use by other modules:

- VPC and subnet IDs
- Security group IDs
- Route table IDs
- NAT Gateway information
- VPC endpoint IDs

## Requirements

- Terraform >= 1.0
- AWS Provider >= 4.0
- At least 2 availability zones in the region

## Cost Considerations

| Resource | Cost Impact | Optimization |
|----------|-------------|--------------|
| NAT Gateway | High | Use single NAT for dev |
| VPC Endpoints | Medium | Enable for prod only |
| EIP | Low | Only with NAT Gateways |
| Subnets | None | No additional cost |

## Security Best Practices

- Network segmentation with separate subnets
- Security groups with least privilege
- No direct internet access to app/db tiers
- VPC endpoints for secure AWS service access
- Optional bastion host for administrative access
