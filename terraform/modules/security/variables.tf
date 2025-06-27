variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "kms_deletion_window" {
  description = "Number of days to wait before deleting KMS key"
  type        = number
  default     = 7
}

# Application secrets
variable "jwt_secret" {
  description = "JWT secret for application (leave empty to auto-generate)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "api_key" {
  description = "API key for external services (leave empty to auto-generate)"
  type        = string
  default     = ""
  sensitive   = true
}

# Application parameters (non-sensitive configuration)
variable "app_parameters" {
  description = "Application configuration parameters"
  type = map(object({
    value  = string
    secure = bool
  }))
  default = {
    app_name = {
      value  = "skillup-platform"
      secure = false
    }
    log_level = {
      value  = "INFO"
      secure = false
    }
    max_connections = {
      value  = "100"
      secure = false
    }
    session_timeout = {
      value  = "3600"
      secure = false
    }
  }
}

# CI/CD Configuration
variable "enable_cicd_role" {
  description = "Enable CI/CD IAM role for GitHub Actions"
  type        = bool
  default     = true
}

variable "github_repository" {
  description = "GitHub repository in format 'owner/repo'"
  type        = string
  default     = ""
}

variable "github_oidc_provider_arn" {
  description = "ARN of GitHub OIDC provider"
  type        = string
  default     = ""
}

# Additional IAM policies
variable "additional_ecs_policies" {
  description = "Additional IAM policy ARNs to attach to ECS task role"
  type        = list(string)
  default     = []
}

variable "additional_cicd_policies" {
  description = "Additional IAM policy ARNs to attach to CI/CD role"
  type        = list(string)
  default     = []
}

# Secret rotation
variable "enable_secret_rotation" {
  description = "Enable automatic secret rotation"
  type        = bool
  default     = false
}

variable "secret_rotation_days" {
  description = "Number of days between secret rotations"
  type        = number
  default     = 30
}

# Additional secrets
variable "additional_secrets" {
  description = "Additional secrets to create in Secrets Manager"
  type = map(object({
    description = string
    value       = string
  }))
  default   = {}
  sensitive = true
}

# Tags
variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "flask_secret" {
  description = "Flask secret key for application (leave empty to auto-generate)"
  type        = string
  default     = ""
  sensitive   = true
}
