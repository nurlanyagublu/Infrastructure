# ============================================================================
# NETWORKING MODULE VARIABLES
# ============================================================================

# ============================================================================
# Project Configuration
# ============================================================================

variable "project_name" {
  description = "Name of the project"
  type        = string
  validation {
    condition     = length(var.project_name) > 0
    error_message = "Project name must not be empty."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be one of: dev, prod."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ============================================================================
# VPC Configuration
# ============================================================================

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

# ============================================================================
# Subnet Configuration
# ============================================================================

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  validation {
    condition     = length(var.public_subnet_cidrs) >= 2
    error_message = "At least 2 public subnets are required for high availability."
  }
}

variable "private_app_subnet_cidrs" {
  description = "CIDR blocks for private application subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
  validation {
    condition     = length(var.private_app_subnet_cidrs) >= 2
    error_message = "At least 2 private app subnets are required for high availability."
  }
}

variable "private_db_subnet_cidrs" {
  description = "CIDR blocks for private database subnets"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
  validation {
    condition     = length(var.private_db_subnet_cidrs) >= 2
    error_message = "At least 2 private DB subnets are required for RDS Multi-AZ."
  }
}

# ============================================================================
# Feature Toggles
# ============================================================================

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnet internet access"
  type        = bool
  default     = false
}

variable "enable_vpc_endpoints" {
  description = "Enable VPC endpoints for AWS services"
  type        = bool
  default     = true
}

variable "enable_bastion" {
  description = "Enable bastion host for SSH access"
  type        = bool
  default     = false
}

# ============================================================================
# Application Configuration
# ============================================================================

variable "app_port" {
  description = "Port number for the application"
  type        = number
  default     = 5000
  validation {
    condition     = var.app_port > 0 && var.app_port <= 65535
    error_message = "App port must be between 1 and 65535."
  }
}

# ============================================================================
# Bastion Configuration
# ============================================================================

variable "bastion_allowed_cidrs" {
  description = "CIDR blocks allowed to access bastion host"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Change this to your office IP range
}

# ============================================================================
# Cost Optimization
# ============================================================================

variable "single_nat_gateway" {
  description = "Use single NAT gateway for cost optimization (not recommended for production)"
  type        = bool
  default     = false
}

