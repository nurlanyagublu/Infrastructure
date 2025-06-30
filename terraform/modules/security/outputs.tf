# KMS Key outputs
output "kms_key_id" {
  description = "ID of the KMS key"
  value       = aws_kms_key.main.key_id
}

output "kms_key_arn" {
  description = "ARN of the KMS key"
  value       = aws_kms_key.main.arn
}

output "kms_alias_name" {
  description = "Name of the KMS key alias"
  value       = aws_kms_alias.main.name
}

# IAM Role outputs
output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_execution_role_name" {
  description = "Name of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution.name
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  value       = aws_iam_role.ecs_task.arn
}

output "ecs_task_role_name" {
  description = "Name of the ECS task role"
  value       = aws_iam_role.ecs_task.name
}

output "cicd_role_arn" {
  description = "ARN of the CI/CD role"
  value       = var.enable_cicd_role ? aws_iam_role.cicd[0].arn : null
}

output "cicd_role_name" {
  description = "Name of the CI/CD role"
  value       = var.enable_cicd_role ? aws_iam_role.cicd[0].name : null
}

# Secrets Manager outputs
output "app_secrets_arn" {
  description = "ARN of the application secrets"
  value       = aws_secretsmanager_secret.app_secrets.arn
}

output "app_secrets_name" {
  description = "Name of the application secrets"
  value       = aws_secretsmanager_secret.app_secrets.name
}

output "app_secrets_version_id" {
  description = "Version ID of the application secrets"
  value       = aws_secretsmanager_secret_version.app_secrets.version_id
}

# Parameter Store outputs
output "parameter_names" {
  description = "Names of the SSM parameters created"
  value       = [for param in aws_ssm_parameter.app_config : param.name]
}

output "parameter_arns" {
  description = "ARNs of the SSM parameters created"
  value       = [for param in aws_ssm_parameter.app_config : param.arn]
}

# Generated secrets (for reference only - actual values are stored securely)
output "jwt_secret_generated" {
  description = "Whether JWT secret was auto-generated"
  value       = true # Always auto-generated now
}

output "api_key_generated" {
  description = "Whether API key was auto-generated"
  value       = true # Always auto-generated now
}

# Security configuration summary
output "security_summary" {
  description = "Summary of security resources created"
  value = {
    kms_key_created          = true
    ecs_roles_created        = true
    secrets_manager_created  = true
    parameter_store_created  = true
    cicd_role_created        = var.enable_cicd_role
    secret_rotation_enabled  = var.enable_secret_rotation
    parameters_count         = length(var.app_parameters)
    additional_secrets_count = length(var.additional_secrets)
  }
}

output "flask_secret_generated" {
  description = "Whether Flask secret was auto-generated"
  value       = true # Always auto-generated now
}
