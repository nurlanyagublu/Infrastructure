# ============================================================================
# ECS MODULE VARIABLES
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
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ============================================================================
# Network Configuration
# ============================================================================

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "At least 2 public subnet IDs are required for ALB."
  }
}

variable "private_app_subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
  validation {
    condition     = length(var.private_app_subnet_ids) >= 2
    error_message = "At least 2 private subnet IDs are required for ECS."
  }
}

variable "alb_security_group_id" {
  description = "Security group ID for ALB"
  type        = string
}

variable "ecs_security_group_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

# ============================================================================
# Database Configuration
# ============================================================================

variable "db_credentials_secret_arn" {
  description = "ARN of the Secrets Manager secret containing database credentials"
  type        = string
}

# ============================================================================
# Application Configuration
# ============================================================================

variable "app_port" {
  description = "Port number for the application"
  type        = number
  default     = 8080
  validation {
    condition     = var.app_port > 0 && var.app_port <= 65535
    error_message = "App port must be between 1 and 65535."
  }
}

variable "app_image_tag" {
  description = "Docker image tag for the application"
  type        = string
  default     = "latest"
}

variable "health_check_path" {
  description = "Health check path for ALB target group"
  type        = string
  default     = "/api/health"
}

# ============================================================================
# ECS Configuration
# ============================================================================

variable "task_cpu" {
  description = "CPU units for the ECS task (1024 = 1 vCPU)"
  type        = number
  default     = 256
  validation {
    condition = contains([
      256, 512, 1024, 2048, 4096
    ], var.task_cpu)
    error_message = "Task CPU must be one of: 256, 512, 1024, 2048, 4096."
  }
}

variable "task_memory" {
  description = "Memory (MB) for the ECS task"
  type        = number
  default     = 512
  validation {
    condition     = var.task_memory >= 512 && var.task_memory <= 30720
    error_message = "Task memory must be between 512 and 30720 MB."
  }
}

variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1
  validation {
    condition     = var.desired_count >= 1 && var.desired_count <= 100
    error_message = "Desired count must be between 1 and 100."
  }
}

# ============================================================================
# Fargate Configuration
# ============================================================================

variable "fargate_base_capacity" {
  description = "Base capacity for Fargate provider"
  type        = number
  default     = 1
}

variable "fargate_weight" {
  description = "Weight for Fargate provider"
  type        = number
  default     = 100
}

variable "enable_fargate_spot" {
  description = "Enable Fargate Spot for cost optimization"
  type        = bool
  default     = true
}

variable "fargate_spot_weight" {
  description = "Weight for Fargate Spot provider"
  type        = number
  default     = 70
}

# ============================================================================
# Auto Scaling Configuration
# ============================================================================

variable "enable_autoscaling" {
  description = "Enable auto scaling for ECS service"
  type        = bool
  default     = true
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of tasks for auto scaling"
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of tasks for auto scaling"
  type        = number
  default     = 5
}

variable "autoscaling_cpu_target" {
  description = "Target CPU utilization for auto scaling"
  type        = number
  default     = 80
  validation {
    condition     = var.autoscaling_cpu_target >= 10 && var.autoscaling_cpu_target <= 90
    error_message = "CPU target must be between 10 and 90."
  }
}

variable "autoscaling_memory_target" {
  description = "Target memory utilization for auto scaling"
  type        = number
  default     = 85
  validation {
    condition     = var.autoscaling_memory_target >= 10 && var.autoscaling_memory_target <= 90
    error_message = "Memory target must be between 10 and 90."
  }
}

# ============================================================================
# Load Balancer Configuration
# ============================================================================

variable "enable_https" {
  description = "Enable HTTPS listener on ALB"
  type        = bool
  default     = false
}

variable "enable_https_redirect" {
  description = "Redirect HTTP to HTTPS"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ARN of SSL certificate for HTTPS"
  type        = string
  default     = null
}

variable "ssl_policy" {
  description = "SSL policy for HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = true
}

# ============================================================================
# Deployment Configuration
# ============================================================================

variable "deployment_maximum_percent" {
  description = "Maximum percentage of tasks that can be running during deployment"
  type        = number
  default     = 200
  validation {
    condition     = var.deployment_maximum_percent >= 100 && var.deployment_maximum_percent <= 200
    error_message = "Deployment maximum percent must be between 100 and 200."
  }
}

variable "deployment_minimum_healthy_percent" {
  description = "Minimum percentage of healthy tasks during deployment"
  type        = number
  default     = 50
  validation {
    condition     = var.deployment_minimum_healthy_percent >= 0 && var.deployment_minimum_healthy_percent <= 100
    error_message = "Deployment minimum healthy percent must be between 0 and 100."
  }
}

# ============================================================================
# Monitoring Configuration
# ============================================================================

variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 3
  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch value."
  }
}

# ============================================================================
# ECR Configuration
# ============================================================================

variable "enable_image_scanning" {
  description = "Enable image scanning on ECR repository"
  type        = bool
  default     = true
}

variable "ecr_image_count" {
  description = "Number of images to keep in ECR repository"
  type        = number
  default     = 10
  validation {
    condition     = var.ecr_image_count >= 1 && var.ecr_image_count <= 100
    error_message = "ECR image count must be between 1 and 100."
  }
}

# ============================================================================
# Service Discovery Configuration
# ============================================================================

variable "enable_service_discovery" {
  description = "Enable service discovery for ECS service"
  type        = bool
  default     = false
}

# ============================================================================
# CloudWatch Alarms Configuration
# ============================================================================

variable "enable_cloudwatch_alarms" {
  description = "Enable CloudWatch alarms for ECS and ALB"
  type        = bool
  default     = false
}

variable "enable_cloudwatch_dashboard" {
  description = "Enable CloudWatch dashboard for monitoring"
  type        = bool
  default     = false
}

variable "alarm_sns_topic_arn" {
  description = "SNS topic ARN for alarm notifications"
  type        = string
  default     = null
}

variable "cpu_alarm_threshold" {
  description = "CPU utilization threshold for alarm (percentage)"
  type        = number
  default     = 80
  validation {
    condition     = var.cpu_alarm_threshold >= 0 && var.cpu_alarm_threshold <= 100
    error_message = "CPU alarm threshold must be between 0 and 100."
  }
}

variable "memory_alarm_threshold" {
  description = "Memory utilization threshold for alarm (percentage)"
  type        = number
  default     = 80
  validation {
    condition     = var.memory_alarm_threshold >= 0 && var.memory_alarm_threshold <= 100
    error_message = "Memory alarm threshold must be between 0 and 100."
  }
}

variable "response_time_alarm_threshold" {
  description = "Response time threshold for alarm (seconds)"
  type        = number
  default     = 2.0
}

variable "error_5xx_alarm_threshold" {
  description = "5XX error count threshold for alarm"
  type        = number
  default     = 10
}

variable "min_running_tasks_alarm_threshold" {
  description = "Minimum running tasks threshold for alarm"
  type        = number
  default     = 1
}

# ============================================================================
# Flask Application Secrets
# ============================================================================

variable "app_secrets_arn" {
  description = "ARN of the application secrets from security module"
  type        = string
}


# ============================================================================
# CORS Configuration
# ============================================================================

variable "cors_origins" {
  description = "Comma-separated list of allowed CORS origins"
  type        = string
  default     = "*"
}
