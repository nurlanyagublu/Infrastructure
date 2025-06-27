# ECS Module

This module creates a production-ready ECS Fargate cluster with auto-scaling, load balancing, and comprehensive monitoring for the Flask API.

## Architecture

```
Internet
    ↓
Application Load Balancer (Public Subnets)
    ↓
ECS Fargate Tasks (Private App Subnets)
    ↓
RDS PostgreSQL (Private DB Subnets)
```

## Features

### 🐳 **Container Platform**
- **ECS Fargate** - Serverless containers
- **ECR Repository** - Private Docker registry
- **Auto-scaling** - Based on CPU/Memory metrics
- **Health checks** - Application and load balancer level
- **Blue/Green deployments** - Zero-downtime updates

### 🔒 **Security**
- **Private subnets** - No direct internet access
- **IAM roles** - Least privilege access
- **Secrets Manager** - Secure database credentials
- **Image scanning** - Container vulnerability detection
- **Encryption** - At rest and in transit

### 📊 **Monitoring & Observability**
- **CloudWatch Container Insights** - Container metrics
- **Application logs** - Centralized logging
- **Custom dashboards** - Real-time monitoring
- **Alerting** - Proactive issue detection
- **Performance tracking** - Response times and errors

### 💰 **Cost Optimization**
- **Fargate Spot** - Up to 70% cost savings
- **Auto-scaling** - Pay only for what you use
- **Right-sizing** - Optimized CPU/Memory allocation
- **Log retention** - Configurable retention periods

## Components

### **1. ECS Cluster**
- Fargate capacity providers
- Container Insights enabled
- Spot instance support

### **2. Task Definition**
- Flask application container
- Environment variables
- Secrets integration
- Health checks
- Resource limits

### **3. ECS Service**
- Desired count management
- Rolling deployments
- Load balancer integration
- Auto-scaling policies

### **4. Application Load Balancer**
- HTTP/HTTPS listeners
- Health checks
- SSL termination
- Path-based routing

### **5. Auto Scaling**
- CPU-based scaling
- Memory-based scaling
- Target tracking policies
- Min/Max capacity limits

## Usage

### Development Environment
```hcl
module "ecs" {
  source = "./modules/ECS"

  project_name = "realworld"
  environment  = "dev"

  # Network Configuration
  vpc_id                 = module.networking.vpc_id
  public_subnet_ids      = module.networking.public_subnet_ids
  private_app_subnet_ids = module.networking.private_app_subnet_ids
  alb_security_group_id  = module.networking.alb_security_group_id
  ecs_security_group_id  = module.networking.ecs_security_group_id

  # Database Configuration
  db_credentials_secret_arn = module.database.db_credentials_secret_arn

  # Cost-optimized settings for development
  task_cpu                = 256    # 0.25 vCPU
  task_memory            = 512     # 512 MB
  desired_count          = 1       # Single instance
  enable_fargate_spot    = true    # Cost savings
  enable_autoscaling     = false   # Disable auto-scaling
  
  # Monitoring
  enable_cloudwatch_alarms     = false  # Disable alarms
  enable_cloudwatch_dashboard  = false  # Disable dashboard
  log_retention_days          = 3       # Short retention

  common_tags = {
    Project     = "realworld"
    Environment = "dev"
  }
}
```

### Production Environment
```hcl
module "ecs" {
  source = "./modules/ECS"

  project_name = "realworld"
  environment  = "prod"

  # Network Configuration
  vpc_id                 = module.networking.vpc_id
  public_subnet_ids      = module.networking.public_subnet_ids
  private_app_subnet_ids = module.networking.private_app_subnet_ids
  alb_security_group_id  = module.networking.alb_security_group_id
  ecs_security_group_id  = module.networking.ecs_security_group_id

  # Database Configuration
  db_credentials_secret_arn = module.database.db_credentials_secret_arn

  # Production settings
  task_cpu                = 512    # 0.5 vCPU
  task_memory            = 1024    # 1024 MB
  desired_count          = 2       # Multiple instances
  enable_fargate_spot    = false   # Consistent performance
  
  # Auto-scaling configuration
  enable_autoscaling         = true
  autoscaling_min_capacity   = 2
  autoscaling_max_capacity   = 10
  autoscaling_cpu_target     = 70
  autoscaling_memory_target  = 80

  # HTTPS configuration
  enable_https              = true
  enable_https_redirect     = true
  certificate_arn          = module.acm.certificate_arn

  # Monitoring
  enable_cloudwatch_alarms     = true
  enable_cloudwatch_dashboard  = true
  log_retention_days          = 30

  common_tags = {
    Project     = "realworld"
    Environment = "prod"
  }
}
```

## Flask Application Integration

### **Environment Variables**
The ECS task automatically provides these environment variables:

```python
import os
import boto3
import json

# Environment configuration
ENV = os.environ.get('ENV', 'dev')
PORT = int(os.environ.get('PORT', 5000))
AWS_REGION = os.environ.get('AWS_DEFAULT_REGION')

# Database configuration from Secrets Manager
DB_SECRET_ARN = os.environ.get('DB_SECRET_ARN')

def get_db_credentials():
    """Retrieve database credentials from AWS Secrets Manager"""
    client = boto3.client('secretsmanager', region_name=AWS_REGION)
    response = client.get_secret_value(SecretId=DB_SECRET_ARN)
    return json.loads(response['SecretString'])

# Flask app configuration
def create_app():
    app = Flask(__name__)
    
    # Database configuration
    db_creds = get_db_credentials()
    app.config['SQLALCHEMY_DATABASE_URI'] = (
        f"postgresql://{db_creds['username']}:{db_creds['password']}"
        f"@{db_creds['host']}:{db_creds['port']}/{db_creds['dbname']}"
    )
    
    return app
```

### **Health Check Endpoint**
```python
@app.route('/health')
def health_check():
    """Health check endpoint for ALB"""
    try:
        # Check database connection
        db.session.execute('SELECT 1')
        return {'status': 'healthy', 'timestamp': datetime.utcnow().isoformat()}
    except Exception as e:
        return {'status': 'unhealthy', 'error': str(e)}, 503
```

### **Dockerfile Example**
```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:${PORT}/health || exit 1

# Expose port
EXPOSE ${PORT}

# Run application
CMD ["python", "app.py"]
```

## Deployment Process

### **1. Build and Push Image**
```bash
# Get ECR login token
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <ecr-url>

# Build image
docker build -t realworld-flask-api .

# Tag image
docker tag realworld-flask-api:latest <ecr-url>:latest

# Push image
docker push <ecr-url>:latest
```

### **2. Update ECS Service**
```bash
# Update service (triggers rolling deployment)
aws ecs update-service \
  --cluster realworld-prod-cluster \
  --service realworld-prod-service \
  --force-new-deployment
```

## Monitoring & Alerts

### **CloudWatch Metrics**
- **ECS Service**: CPU, Memory, Running Tasks
- **Application Load Balancer**: Request count, Response time, Error rates
- **Target Group**: Healthy/Unhealthy hosts
- **Container Insights**: Detailed container metrics

### **Alarms**
- High CPU utilization (>80%)
- High memory utilization (>80%)
- High response times (>2s)
- 5XX error rate (>10 errors)
- Low running task count

### **Dashboard**
Real-time visualization of:
- Service performance metrics
- Load balancer statistics
- Target group health
- Auto-scaling activity

## Cost Analysis

| Environment | CPU/Memory | Desired Count | Spot | Est. Monthly Cost |
|-------------|------------|---------------|------|-------------------|
| **Development** | 256/512 | 1 | Yes | ~$5-10 |
| **Staging** | 512/1024 | 1 | No | ~$15-25 |
| **Production** | 512/1024 | 2-10 | No | ~$30-150 |

## Security Features

### **Network Security**
- Private subnets for ECS tasks
- Security groups with minimal access
- No direct internet connectivity
- VPC endpoints for AWS services

### **Application Security**
- Non-root container execution
- Read-only file systems
- Resource limits and quotas
- Image vulnerability scanning

### **Access Control**
- IAM roles with least privilege
- Secrets Manager for credentials
- Encrypted storage and transit
- CloudTrail audit logging

## Scaling Behavior

### **Auto Scaling Triggers**
```hcl
# Scale out when CPU > 70% for 5 minutes
# Scale in when CPU < 70% for 5 minutes
# Scale out when Memory > 80% for 5 minutes
# Scale in when Memory < 80% for 5 minutes
```

### **Deployment Strategy**
- **Rolling updates** with configurable percentages
- **Zero-downtime deployments**
- **Automatic rollback** on health check failures
- **Blue/green deployment** support

## Troubleshooting

### **Common Issues**
1. **Service not starting**: Check CloudWatch logs
2. **Health checks failing**: Verify health endpoint
3. **High CPU/Memory**: Review auto-scaling settings
4. **Database connection errors**: Check Secrets Manager access

### **Useful Commands**
```bash
# View service events
aws ecs describe-services --cluster <cluster> --services <service>

# View task logs
aws logs get-log-events --log-group-name /ecs/realworld-prod

# Check task definition
aws ecs describe-task-definition --task-definition <family>:revision
```

## Requirements

- Terraform >= 1.0
- AWS Provider >= 4.0
- VPC and networking module
- Database module (for Secrets Manager ARN)
- Docker image in ECR repository
