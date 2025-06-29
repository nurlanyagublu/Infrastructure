# Project Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "nurlan-yagublu"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Networking Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.1.0.0/16"  # Different CIDR for prod
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]  # More AZs for prod
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.1.10.0/24", "10.1.20.0/24", "10.1.30.0/24"]
}

# Database Configuration
variable "db_engine" {
  description = "Database engine"
  type        = string
  default     = "postgres"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
  default     = "15.4"
}

variable "db_instance_class" {
  description = "Database instance class"
  type        = string
  default     = "db.t3.small"  # Larger for production
}

variable "db_allocated_storage" {
  description = "Initial allocated storage in GB"
  type        = number
  default     = 100  # More storage for prod
}

variable "db_max_allocated_storage" {
  description = "Maximum allocated storage in GB"
  type        = number
  default     = 1000  # Higher limit for prod
}

variable "db_storage_type" {
  description = "Storage type"
  type        = string
  default     = "gp3"  # Better performance for prod
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "nurlan-yagublu_prod"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "backup_window" {
  description = "Backup window"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Maintenance window"
  type        = string
  default     = "sun:04:00-sun:06:00"  # Longer window for prod
}

# ECS Configuration
variable "app_image" {
  description = "Docker image for the application"
  type        = string
  default     = "nginx:latest"  # Update with your production image
}

variable "app_port" {
  description = "Port the application runs on"
  type        = number
  default     = 80
}

# Domain Configuration
variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "example.com"  # Update with your domain
}

# Security Configuration
variable "enable_cicd_role" {
  description = "Enable CI/CD IAM role for GitHub Actions"
  type        = bool
  default     = true
}

variable "github_repository" {
  description = "GitHub repository in format 'owner/repo'"
  type        = string
  default     = "youruser/yourrepo"  # Update with your repo
}

variable "github_oidc_provider_arn" {
  description = "ARN of GitHub OIDC provider"
  type        = string
  default     = ""  # Will be created if not provided
}

# Tags
variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default = {
    Environment = "prod"
    Project     = "nurlan-yagublu"
    Owner       = "Nurlan-Prod"
    CostCenter  = "production"
  }
}
