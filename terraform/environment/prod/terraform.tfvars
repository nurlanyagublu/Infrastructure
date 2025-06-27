# Project Configuration
project_name = "nurlan-yagublu"
aws_region   = "us-east-1"

# Networking Configuration - Production
vpc_cidr             = "10.1.0.0/16"  # Different CIDR from dev
availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]  # 3 AZs for HA
public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
private_subnet_cidrs = ["10.1.10.0/24", "10.1.20.0/24", "10.1.30.0/24"]

# Database Configuration - Production-grade
db_engine        = "postgres"
db_engine_version = "15.8"
db_instance_class = "db.t3.small"     # More powerful for prod

# Storage Configuration
db_allocated_storage     = 100        # More storage
db_max_allocated_storage = 1000       # Higher scaling limit
db_storage_type         = "gp3"       # Better performance

# Database Details
db_name     = "nurlanyagublu_prod"
db_username = "dbadmin"
# db_password should be set via environment variable: TF_VAR_db_password

# Backup Configuration - Comprehensive for prod
backup_window      = "03:00-04:00"
maintenance_window = "sun:04:00-sun:06:00"

# ECS Configuration - Production

# Domain Configuration
domain_name = "nurlanskillup.pp.ua"  # Update with your domain

# Security Configuration
enable_cicd_role    = true
github_repository   = "youruser/yourrepo"  # Update with your GitHub repo
# github_oidc_provider_arn = ""  # Will be created automatically

# Tags
tags = {
  Environment = "prod"
  Project     = "nurlan-yagublu"
  Owner       = "nurlan.yagublu@nixs.com"
  CostCenter  = "production"
  Backup      = "required"
  Monitoring  = "critical"
}

# ============================================================================
# Flask Application Configuration - Production
# ============================================================================

# Application Configuration
app_image = ".dkr.ecr.us-east-1.amazonaws.com/nurlan-yagublu-prod-flask-api:latest"
app_port  = 8080


# CORS Configuration - Production (strict for security)
cors_origins = "https://nurlanskillup.pp.ua,https://www.nurlanskillup.pp.ua"

# Health Check Configuration
health_check_path = "/api/health"

# Flask Secrets (Managed by Security Module)
# The security module automatically generates and manages all secrets
# Secrets are stored in: nurlan-yagublu/prod/app-secrets
# Contains: flask_secret, jwt_secret, api_key, encryption_key
