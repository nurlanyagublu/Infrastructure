# Database Module

This module creates a production-ready RDS PostgreSQL database with high availability, security, and monitoring.

## Features

### 🔒 **Security**
- **Encryption at rest** with KMS
- **Private subnet deployment** (no public access)
- **Secrets Manager** for credential storage
- **Security group** integration from networking module

### 🏗️ **High Availability**
- **Multi-AZ deployment** for automatic failover
- **Automated backups** with configurable retention
- **Read replicas** for scaling (optional)
- **Maintenance windows** for zero-downtime updates

### 📊 **Monitoring & Performance**
- **Performance Insights** enabled
- **Enhanced monitoring** with CloudWatch
- **Custom parameter group** for optimization
- **CloudWatch alarms** for proactive monitoring
- **Database dashboard** for visualization

### 💰 **Cost Optimization**
- **Environment-specific sizing**
- **Auto-scaling storage**
- **Configurable features** for dev/prod
- **Read replica** options

## Architecture

```
Private DB Subnets (Multi-AZ)
├── RDS PostgreSQL (Primary)
├── RDS PostgreSQL (Standby) - Multi-AZ
└── Read Replica (Optional)
    ↓
Secrets Manager (Credentials)
    ↓
CloudWatch (Monitoring & Alarms)
```

## Usage

### Development Environment
```hcl
module "database" {
  source = "./modules/database"

  project_name = "realworld"
  environment  = "dev"

  # Network Configuration
  private_db_subnet_ids = module.networking.private_db_subnet_ids
  rds_security_group_id = module.networking.rds_security_group_id

  # Cost-optimized settings for development
  db_instance_class       = "db.t3.micro"
  multi_az               = false
  backup_retention_period = 1
  deletion_protection    = false
  create_read_replica    = false

  # Monitoring
  monitoring_interval           = 0    # Disable enhanced monitoring
  performance_insights_enabled = false
  create_cloudwatch_alarms     = false

  common_tags = {
    Project     = "realworld"
    Environment = "dev"
  }
}
```

### Production Environment
```hcl
module "database" {
  source = "./modules/database"

  project_name = "realworld"
  environment  = "prod"

  # Network Configuration
  private_db_subnet_ids = module.networking.private_db_subnet_ids
  rds_security_group_id = module.networking.rds_security_group_id

  # Production settings
  db_instance_class       = "db.t3.small"
  multi_az               = true
  backup_retention_period = 7
  deletion_protection    = true
  create_read_replica    = true
  replica_instance_class = "db.t3.micro"

  # Advanced monitoring
  monitoring_interval           = 60
  performance_insights_enabled = true
  create_cloudwatch_alarms     = true
  create_cloudwatch_dashboard  = true

  common_tags = {
    Project     = "realworld"
    Environment = "prod"
  }
}
```

## Database Configuration

### **Default Settings**
- **Engine**: PostgreSQL 15.4
- **Port**: 5432
- **Database**: realworlddb
- **User**: realworld_user
- **Storage**: 20GB (auto-scaling to 100GB)

### **Parameter Group Optimizations**
- `pg_stat_statements` for query analysis
- Query logging for slow queries (>1s)
- Optimized connection limits
- Performance monitoring enabled

## Security Features

### **Credentials Management**
```json
{
  "username": "realworld_user",
  "password": "auto-generated-32-char-password",
  "host": "realworld-prod-postgres.xxxxx.region.rds.amazonaws.com",
  "port": 5432,
  "dbname": "realworlddb",
  "engine": "postgres"
}
```

### **Access Control**
- Database accessible only from ECS security group
- No public access
- Encrypted connections required
- IAM database authentication (optional)

## Monitoring & Alerts

### **CloudWatch Metrics**
- CPU Utilization
- Database Connections
- Free Storage Space
- Read/Write Latency
- Throughput metrics

### **Alarms**
- High CPU usage (>80%)
- Too many connections (>80 concurrent)
- Low storage space (<2GB)
- Automatic SNS notifications

## Cost Comparison

| Environment | Instance | Multi-AZ | Monitoring | Est. Monthly Cost |
|-------------|----------|----------|------------|-------------------|
| **Development** | t3.micro | No | Basic | ~$15-20 |
| **Staging** | t3.small | No | Enhanced | ~$30-40 |
| **Production** | t3.small | Yes | Full | ~$60-80 |

## Integration with Flask

### **Environment Variables**
```python
# Flask application configuration
DB_HOST = module.database.flask_db_config.DB_HOST
DB_PORT = module.database.flask_db_config.DB_PORT
DB_NAME = module.database.flask_db_config.DB_NAME
DB_SECRET_ARN = module.database.flask_db_config.DB_SECRET_ARN
```

### **Connection Example**
```python
import boto3
import json
import psycopg2

# Get credentials from Secrets Manager
secrets_client = boto3.client('secretsmanager')
secret_value = secrets_client.get_secret_value(SecretId=DB_SECRET_ARN)
credentials = json.loads(secret_value['SecretString'])

# Connect to database
connection = psycopg2.connect(
    host=credentials['host'],
    port=credentials['port'],
    database=credentials['dbname'],
    user=credentials['username'],
    password=credentials['password']
)
```

## Backup & Recovery

### **Automated Backups**
- Daily backups during maintenance window
- Point-in-time recovery available
- Cross-region backup replication (optional)
- Final snapshot on deletion

### **Disaster Recovery**
- Multi-AZ for automatic failover
- Read replicas for additional redundancy
- Backup restoration procedures documented
- RTO: <5 minutes, RPO: <1 minute

## Requirements

- Terraform >= 1.0
- AWS Provider >= 4.0
- Private subnets from networking module
- Security group from networking module
