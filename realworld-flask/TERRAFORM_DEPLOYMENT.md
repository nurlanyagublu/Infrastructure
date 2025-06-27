# RealWorld Flask - ECS Fargate Deployment Guide

This guide explains how to deploy the RealWorld Flask application using Terraform with ECS Fargate architecture.

## Architecture Overview

```
Internet -> Route 53 -> CloudFront (Frontend) -> S3 (Vue3 App)
Internet -> Route 53 -> ALB -> ECS Fargate (Flask API) -> RDS PostgreSQL
```

### Components:
- **Frontend**: Vue3 app served via S3 + CloudFront CDN
- **Backend**: Flask API on ECS Fargate (cost-effective, serverless containers)  
- **Database**: RDS PostgreSQL (managed service)
- **Load Balancing**: Application Load Balancer (ALB)
- **Domain & SSL**: Route 53 + ACM (AWS Certificate Manager)

## Environment Configuration

### Development Environment (Local)
- Uses local PostgreSQL container via Docker Compose
- Debug mode enabled
- Permissive CORS settings

### Production Environment (AWS)
- ECS Fargate tasks
- RDS PostgreSQL with SSL
- ALB with SSL termination
- Route 53 DNS management

## ECS Fargate Configuration

### Task Definition Requirements
```json
{
  "family": "realworld-flask",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "256",
  "memory": "512",
  "executionRoleArn": "arn:aws:iam::account:role/ecsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::account:role/ecsTaskRole"
}
```

### Container Configuration
```json
{
  "name": "realworld-flask",
  "image": "your-registry/realworld-flask:latest",
  "portMappings": [
    {
      "containerPort": 8080,
      "protocol": "tcp"
    }
  ],
  "essential": true,
  "logConfiguration": {
    "logDriver": "awslogs",
    "options": {
      "awslogs-group": "/ecs/realworld-flask",
      "awslogs-region": "us-east-1",
      "awslogs-stream-prefix": "ecs"
    }
  }
}
```

## Required Environment Variables for ECS

### Database Configuration (From Terraform Outputs)
```bash
POSTGRES_HOST=${rds_endpoint}
POSTGRES_PORT=5432
POSTGRES_DB=realworlddb
POSTGRES_USER=${rds_username}
POSTGRES_PASSWORD=${rds_password}  # From AWS Secrets Manager
DB_SSL_MODE=require
```

### ECS-Specific Configuration
```bash
FLASK_ENV=production
FLASK_RUN_HOST=0.0.0.0
FLASK_RUN_PORT=8080

# Application Load Balancer Health Checks
ALB_HEALTH_CHECK_PATH=/api/health
ALB_HEALTH_CHECK_GRACE_PERIOD=300

# AWS Region and Service Discovery
AWS_DEFAULT_REGION=us-east-1
SERVICE_NAME=realworld-flask
```

### Security Configuration (AWS Secrets Manager)
```bash
SECRET_KEY=/realworld/production/secret-key
JWT_SECRET_KEY=/realworld/production/jwt-secret
```

### CORS Configuration for CloudFront
```bash
CORS_ORIGINS=https://yourdomain.com,https://www.yourdomain.com,https://d1234567890.cloudfront.net
```

## Database Setup with RDS

### RDS Configuration
When `terraform apply` runs, it creates:
- ✅ RDS PostgreSQL instance (automatically)
- ✅ VPC security groups for ECS ↔ RDS communication
- ✅ Subnet groups for high availability
- ✅ Automated backups and monitoring
- ✅ SSL/TLS encryption in transit

### Database Initialization in ECS
The Flask app automatically:
1. Waits for RDS availability (retry logic)
2. Runs Alembic migrations on startup
3. Creates tables and indexes
4. Reports readiness via `/api/ready`

## Load Balancer Health Checks

### ALB Target Group Configuration
```bash
# Health Check Settings
Health Check Path: /api/health
Health Check Port: 8080
Healthy Threshold: 2
Unhealthy Threshold: 3
Health Check Timeout: 5 seconds
Health Check Interval: 30 seconds
Success Codes: 200
```

### ECS Service Health Checks
```bash
# Container Health Check (Dockerfile)
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/api/health || exit 1
```

## Deployment Process

### 1. Build and Push to ECR
```bash
# Get ECR login token
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com

# Build the image
docker build -t realworld-flask .

# Tag for ECR
docker tag realworld-flask:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/realworld-flask:latest

# Push to ECR
docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/realworld-flask:latest
```

### 2. Deploy Infrastructure with Terraform
```bash
terraform init
terraform plan -var="environment=production"
terraform apply
```

### 3. ECS Service Deployment
Terraform will create:
- ECS Cluster
- ECS Service with Auto Scaling
- Task Definition
- ALB Target Group
- Security Groups
- Service Discovery (optional)

## Monitoring and Health Checks

### Application Endpoints
- **`/api/health`** - ALB health check endpoint
- **`/api/ready`** - Kubernetes-style readiness probe
- **`/api/metrics`** - Application metrics for monitoring
- **`/api/ping`** - Simple connectivity test

### CloudWatch Integration
```bash
# Log Groups
/ecs/realworld-flask

# Metrics
- ECS Service metrics
- ALB target health
- RDS connection metrics
- Custom application metrics
```

## Auto Scaling Configuration

### ECS Service Auto Scaling
```bash
# Scale based on CPU/Memory
Min Capacity: 1
Max Capacity: 10
Target CPU Utilization: 70%
Target Memory Utilization: 80%

# Scale based on ALB Request Count
Target Requests per Target: 100
```

### Database Connection Pooling for Scaling
```bash
# Production pool settings
DB_POOL_SIZE=20
DB_MAX_OVERFLOW=40
DB_POOL_TIMEOUT=30
DB_POOL_RECYCLE=3600
```

## Security Configuration

### VPC Security Groups
```bash
# ECS Security Group
Inbound: Port 8080 from ALB Security Group
Outbound: Port 5432 to RDS Security Group
Outbound: Port 443 for AWS API calls

# RDS Security Group  
Inbound: Port 5432 from ECS Security Group
```

### IAM Roles
```bash
# ECS Task Execution Role
- AmazonECSTaskExecutionRolePolicy
- CloudWatch Logs permissions
- ECR pull permissions

# ECS Task Role
- Secrets Manager read permissions
- CloudWatch metrics permissions
```

## Cost Optimization

### Fargate Pricing Tiers
```bash
# Development
CPU: 0.25 vCPU, Memory: 0.5 GB
Estimated: ~$5-10/month

# Production
CPU: 0.5 vCPU, Memory: 1 GB  
Estimated: ~$15-30/month

# High Traffic
CPU: 1 vCPU, Memory: 2 GB
With Auto Scaling: ~$50-100/month
```

## Terraform Outputs Integration

After `terraform apply`, use these outputs:
```bash
# RDS Outputs
rds_endpoint = "realworld-prod.cluster-xyz.us-east-1.rds.amazonaws.com"
rds_port = "5432"

# ALB Outputs  
alb_dns_name = "realworld-alb-123456789.us-east-1.elb.amazonaws.com"
alb_zone_id = "Z35SXDOTRQ7X7K"

# ECS Outputs
ecs_cluster_name = "realworld-production"
ecs_service_name = "realworld-flask-service"
```

## Troubleshooting

### ECS Task Not Starting
1. Check CloudWatch logs: `/ecs/realworld-flask`
2. Verify ECR image exists and is accessible
3. Check IAM permissions for task execution role
4. Verify environment variables and secrets

### ALB Health Check Failures
1. Check security group rules (ECS ↔ ALB)
2. Verify `/api/health` endpoint responds with 200
3. Check ECS task logs for startup errors
4. Verify container port 8080 is accessible

### Database Connection Issues
1. Check RDS endpoint and port
2. Verify security group rules (ECS ↔ RDS)
3. Test database connectivity from ECS task
4. Check `/api/ready` endpoint for database status

### CORS Issues with Frontend
1. Verify CORS_ORIGINS includes CloudFront domain
2. Check CloudFront is properly routing API calls
3. Verify SSL certificates are valid

## Production Checklist

- [ ] ECR repository created and image pushed
- [ ] RDS instance created and accessible
- [ ] ECS cluster and service running
- [ ] ALB health checks passing
- [ ] Route 53 DNS records configured
- [ ] SSL certificates valid and applied
- [ ] CloudWatch logs and metrics configured
- [ ] Auto scaling policies configured
- [ ] Secrets stored in AWS Secrets Manager
- [ ] Security groups properly configured
- [ ] Database migrations completed
