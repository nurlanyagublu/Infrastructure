# ============================================================================
# DATABASE MODULE VARIABLES
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
    condition     = contains(["dev", "dev2", "staging", "prod"], var.environment)
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

variable "private_db_subnet_ids" {
  description = "List of private database subnet IDs"
  type        = list(string)
  validation {
    condition     = length(var.private_db_subnet_ids) >= 2
    error_message = "At least 2 private DB subnet IDs are required for Multi-AZ."
  }
}

variable "rds_security_group_id" {
  description = "Security group ID for RDS instance"
  type        = string
}

# ============================================================================
# Database Configuration
# ============================================================================

variable "db_name" {
  description = "Name of the database to create"
  type        = string
  default     = "realworlddb"
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.db_name))
    error_message = "Database name must start with a letter and contain only alphanumeric characters and underscores."
  }
}

variable "db_username" {
  description = "Username for the database"
  type        = string
  default     = "realworld_user"
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.db_username))
    error_message = "Database username must start with a letter and contain only alphanumeric characters and underscores."
  }
}

variable "postgres_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "15.4"
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+$", var.postgres_version))
    error_message = "PostgreSQL version must be in format X.Y (e.g., 15.4)."
  }
}

# ============================================================================
# Instance Configuration
# ============================================================================

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
  validation {
    condition = contains([
      "db.t3.micro", "db.t3.small", "db.t3.medium", "db.t3.large",
      "db.t4g.micro", "db.t4g.small", "db.t4g.medium", "db.t4g.large",
      "db.r5.large", "db.r5.xlarge", "db.r5.2xlarge"
    ], var.db_instance_class)
    error_message = "DB instance class must be a valid RDS instance type."
  }
}

variable "max_connections" {
  description = "Maximum number of connections to the database"
  type        = string
  default     = "100"
}

# ============================================================================
# Storage Configuration
# ============================================================================

variable "allocated_storage" {
  description = "Initial allocated storage in GB"
  type        = number
  default     = 20
  validation {
    condition     = var.allocated_storage >= 20 && var.allocated_storage <= 65536
    error_message = "Allocated storage must be between 20 and 65536 GB."
  }
}

variable "max_allocated_storage" {
  description = "Maximum allocated storage for auto-scaling in GB"
  type        = number
  default     = 100
  validation {
    condition     = var.max_allocated_storage >= 20 && var.max_allocated_storage <= 65536
    error_message = "Max allocated storage must be between 20 and 65536 GB."
  }
}

variable "storage_type" {
  description = "Storage type for RDS instance"
  type        = string
  default     = "gp3"
  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2"], var.storage_type)
    error_message = "Storage type must be one of: gp2, gp3, io1, io2."
  }
}

variable "kms_key_id" {
  description = "KMS key ID for encryption (if null, uses default AWS managed key)"
  type        = string
  default     = null
}

# ============================================================================
# High Availability & Backup
# ============================================================================

variable "multi_az" {
  description = "Enable Multi-AZ deployment for high availability"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 7
  validation {
    condition     = var.backup_retention_period >= 0 && var.backup_retention_period <= 35
    error_message = "Backup retention period must be between 0 and 35 days."
  }
}

variable "backup_window" {
  description = "Preferred backup window (UTC)"
  type        = string
  default     = "03:00-04:00"
  validation {
    condition     = can(regex("^[0-9]{2}:[0-9]{2}-[0-9]{2}:[0-9]{2}$", var.backup_window))
    error_message = "Backup window must be in format HH:MM-HH:MM."
  }
}

variable "maintenance_window" {
  description = "Preferred maintenance window (UTC)"
  type        = string
  default     = "sun:04:00-sun:05:00"
  validation {
    condition     = can(regex("^[a-z]{3}:[0-9]{2}:[0-9]{2}-[a-z]{3}:[0-9]{2}:[0-9]{2}$", var.maintenance_window))
    error_message = "Maintenance window must be in format ddd:HH:MM-ddd:HH:MM."
  }
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when deleting"
  type        = bool
  default     = false
}

# ============================================================================
# Monitoring Configuration
# ============================================================================

variable "monitoring_interval" {
  description = "Enhanced monitoring interval in seconds (0 to disable)"
  type        = number
  default     = 0
  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.monitoring_interval)
    error_message = "Monitoring interval must be one of: 0, 1, 5, 10, 15, 30, 60."
  }
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch"
  type        = list(string)
  default     = ["postgresql"]
  validation {
    condition = alltrue([
      for log_type in var.enabled_cloudwatch_logs_exports :
      contains(["postgresql"], log_type)
    ])
    error_message = "Log types must be valid PostgreSQL log types."
  }
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = false
}

variable "performance_insights_retention_period" {
  description = "Performance Insights retention period in days"
  type        = number
  default     = 7
  validation {
    condition     = contains([7, 731], var.performance_insights_retention_period)
    error_message = "Performance Insights retention period must be 7 or 731 days."
  }
}

# ============================================================================
# Read Replica Configuration
# ============================================================================

variable "create_read_replica" {
  description = "Create a read replica for the database"
  type        = bool
  default     = false
}

variable "replica_instance_class" {
  description = "Instance class for read replica"
  type        = string
  default     = "db.t3.micro"
}

variable "replica_monitoring_interval" {
  description = "Enhanced monitoring interval for read replica"
  type        = number
  default     = 0
  validation {
    condition     = contains([0, 1, 5, 10, 15, 30, 60], var.replica_monitoring_interval)
    error_message = "Replica monitoring interval must be one of: 0, 1, 5, 10, 15, 30, 60."
  }
}

variable "replica_performance_insights_enabled" {
  description = "Enable Performance Insights for read replica"
  type        = bool
  default     = false
}

# ============================================================================
# CloudWatch Monitoring Configuration
# ============================================================================

variable "create_cloudwatch_alarms" {
  description = "Create CloudWatch alarms for database monitoring"
  type        = bool
  default     = false
}

variable "create_cloudwatch_dashboard" {
  description = "Create CloudWatch dashboard for database monitoring"
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

variable "connection_alarm_threshold" {
  description = "Database connection count threshold for alarm"
  type        = number
  default     = 80
}

variable "free_storage_alarm_threshold" {
  description = "Free storage space threshold for alarm (bytes)"
  type        = number
  default     = 2147483648 # 2GB in bytes
}

# ============================================================================
# Demo Mode Configuration
# ============================================================================

variable "demo_mode" {
  description = "Enable demo mode for ultra-low costs (not for production)"
  type        = bool
  default     = false
}

variable "use_rds_serverless" {
  description = "Use RDS Serverless v2 for demo (pay per use)"
  type        = bool
  default     = false
}
