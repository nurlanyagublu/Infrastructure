terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "prod"
      Project     = var.project_name
      ManagedBy   = "terraform"
    }
  }
}

# Security Module - Create first for IAM roles and KMS keys
module "security" {
  source = "../../modules/security"

  project_name = var.project_name
  environment  = "prod"
  aws_region   = var.aws_region

  # CI/CD Configuration
  enable_cicd_role         = var.enable_cicd_role
  github_repository        = var.github_repository
  github_oidc_provider_arn = var.github_oidc_provider_arn

  # Application parameters for production
  app_parameters = {
    app_name = {
      value  = var.project_name
      secure = false
    }
    log_level = {
      value  = "INFO"
      secure = false
    }
    max_connections = {
      value  = "200" # Higher for prod
      secure = false
    }
    session_timeout = {
      value  = "3600" # Standard for prod
      secure = false
    }
  }

  additional_tags = var.tags
}

# Networking Module
module "networking" {
  source = "../../modules/networking"

  project_name = var.project_name
  environment  = "prod"

  # VPC Configuration
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  # Security Groups
  enable_database_sg = true
  enable_ecs_sg      = true
  enable_alb_sg      = true

  tags = var.tags
}

# Database Module
module "database" {
  source = "../../modules/database"

  # Basic Configuration
  identifier     = "${var.project_name}-prod-db"
  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  # Database Configuration
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = var.db_storage_type
  storage_encrypted     = true
  kms_key_id            = module.security.kms_key_arn

  # Database Credentials
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  # Network Configuration
  vpc_id             = module.networking.vpc_id
  subnet_ids         = module.networking.private_subnet_ids
  security_group_ids = [module.networking.database_security_group_id]

  # Backup Configuration (comprehensive for prod)
  backup_retention_period = 30 # 30 days retention for prod
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  # Monitoring (enabled for prod)
  monitoring_interval             = 60 # Enhanced monitoring
  enabled_cloudwatch_logs_exports = ["postgresql"]

  # High Availability (enabled for prod)
  multi_az            = true # Multi-AZ for high availability
  publicly_accessible = false

  # Security (strict for prod)
  deletion_protection       = true  # Prevent accidental deletion
  skip_final_snapshot       = false # Take final snapshot
  final_snapshot_identifier = "${var.project_name}-prod-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  # Performance (enabled for prod)
  performance_insights_enabled = true

  tags = var.tags
}

# S3 Static Website Module
module "s3_static_website" {
  source = "../../modules/s3-static-website"

  project_name = var.project_name
  environment  = "prod"

  # S3 Configuration
  enable_versioning = true
  enable_logging    = true # Enable logging for prod

  # CloudFront (enabled for prod)
  enable_cloudfront = true

  tags = var.tags
}

# Route 53 Module
module "route53" {
  source = "../../modules/route53"

  project_name = var.project_name
  environment  = "prod"

  # Domain configuration for prod
  domain_name   = var.domain_name
  app_subdomain = "app" # app.yourdomian.com
  api_subdomain = "api" # api.yourdomain.com

  # ALB integration (will be available after ECS module)
  alb_dns_name = module.ecs.alb_dns_name
  alb_zone_id  = module.ecs.alb_zone_id

  # Health checks (enabled for prod)
  enable_health_check = true

  aws_region = var.aws_region
}

# ECS Module
module "ecs" {
  source = "../../modules/ECS"

  project_name = var.project_name
  environment  = "prod"

  # VPC Configuration
  vpc_id          = module.networking.vpc_id
  private_subnets = module.networking.private_subnet_ids
  public_subnets  = module.networking.public_subnet_ids

  # Security Groups
  alb_security_group_id = module.networking.alb_security_group_id
  ecs_security_group_id = module.networking.ecs_security_group_id

  # IAM Roles from Security Module
  ecs_task_execution_role_arn = module.security.ecs_task_execution_role_arn
  ecs_task_role_arn           = module.security.ecs_task_role_arn

  # Certificate for HTTPS
  certificate_arn = module.route53.certificate_arn

  # ECS Configuration for production
  cluster_name = "${var.project_name}-prod-cluster"

  # Container Configuration (production sizing)
  app_image        = var.app_image
  app_port         = var.app_port
  container_cpu    = 1024 # Higher for prod
  container_memory = 2048 # Higher for prod

  # Auto Scaling (robust for prod)
  min_capacity  = 2  # Minimum instances for availability
  max_capacity  = 10 # Scale up capability
  desired_count = 3  # Start with 3 instances

  # Database connection
  database_url = "postgresql://${var.db_username}:${var.db_password}@${module.database.db_instance_endpoint}:5432/${var.db_name}"

  # Application secrets
  app_secrets_arn           = module.security.app_secrets_arn
  db_credentials_secret_arn = module.database.db_credentials_secret_arn

  tags = var.tags
}
