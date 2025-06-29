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
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
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
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Initial allocated storage in GB"
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "Maximum allocated storage in GB"
  type        = number
  default     = 100
}

variable "db_storage_type" {
  description = "Storage type"
  type        = string
  default     = "gp2"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "nurlan-yagublu_dev"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "admin"
}

variable "backup_window" {
  description = "Backup window"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

# ECS Configuration
variable "app_image" {
  description = "Docker image for the application"
  type        = string
  default     = "nginx:latest"  # Default image for testing
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
  default     = "nurlanyagublu/infrastructure"  # Update with your repo
}

variable "github_oidc_provider_arn" {
  description = "ARN of GitHub OIDC provider"
  type        = string
  default     = ""  # Will be created if not provided
}

# Application Configuration Variables
variable "cors_origins" {
  description = "CORS origins for the application"
  type        = string
  default     = "http://localhost:3000,http://localhost:4200"
}

variable "health_check_path" {
  description = "Health check path for the application"
  type        = string
  default     = "/api/health"
}

# Tags
variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "nurlan-yagublu"
    Owner       = "Nurlan-Dev"
    CostCenter  = "development"
  }
}
