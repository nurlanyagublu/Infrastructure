# ============================================================================
# DATABASE MODULE OUTPUTS
# ============================================================================

# ============================================================================
# Database Instance Outputs
# ============================================================================

output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.main.id
}

output "db_instance_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.main.arn
}

output "db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "db_instance_port" {
  description = "RDS instance port"
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}

output "db_username" {
  description = "Database username"
  value       = aws_db_instance.main.username
  sensitive   = true
}

# ============================================================================
# Database Credentials (Secrets Manager)
# ============================================================================

output "db_credentials_secret_arn" {
  description = "ARN of the Secrets Manager secret containing database credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "db_credentials_secret_name" {
  description = "Name of the Secrets Manager secret containing database credentials"
  value       = aws_secretsmanager_secret.db_credentials.name
}

# ============================================================================
# Connection Information
# ============================================================================

output "db_connection_info" {
  description = "Database connection information"
  value = {
    host       = aws_db_instance.main.endpoint
    port       = aws_db_instance.main.port
    database   = aws_db_instance.main.db_name
    username   = aws_db_instance.main.username
    secret_arn = aws_secretsmanager_secret.db_credentials.arn
  }
  sensitive = true
}

# ============================================================================
# Subnet Group Information
# ============================================================================

output "db_subnet_group_name" {
  description = "Database subnet group name"
  value       = aws_db_subnet_group.main.name
}

output "db_subnet_group_arn" {
  description = "Database subnet group ARN"
  value       = aws_db_subnet_group.main.arn
}

# ============================================================================
# Parameter Group Information
# ============================================================================

output "db_parameter_group_name" {
  description = "Database parameter group name"
  value       = aws_db_parameter_group.main.name
}

output "db_parameter_group_arn" {
  description = "Database parameter group ARN"
  value       = aws_db_parameter_group.main.arn
}

# ============================================================================
# Monitoring Information
# ============================================================================

output "enhanced_monitoring_role_arn" {
  description = "Enhanced monitoring IAM role ARN"
  value       = var.monitoring_interval > 0 ? aws_iam_role.rds_enhanced_monitoring[0].arn : null
}

# ============================================================================
# Read Replica Information
# ============================================================================

output "read_replica_id" {
  description = "Read replica instance ID"
  value       = var.create_read_replica ? aws_db_instance.read_replica[0].id : null
}

output "read_replica_endpoint" {
  description = "Read replica endpoint"
  value       = var.create_read_replica ? aws_db_instance.read_replica[0].endpoint : null
  sensitive   = true
}

# ============================================================================
# Environment-Specific Connection String
# ============================================================================

output "connection_string" {
  description = "PostgreSQL connection string (without password)"
  value       = "postgresql://${aws_db_instance.main.username}@${aws_db_instance.main.endpoint}:${aws_db_instance.main.port}/${aws_db_instance.main.db_name}"
  sensitive   = true
}

# ============================================================================
# Flask Application Environment Variables
# ============================================================================

output "flask_db_config" {
  description = "Database configuration for Flask application"
  value = {
    DB_HOST       = aws_db_instance.main.endpoint
    DB_PORT       = tostring(aws_db_instance.main.port)
    DB_NAME       = aws_db_instance.main.db_name
    DB_USER       = aws_db_instance.main.username
    DB_SECRET_ARN = aws_secretsmanager_secret.db_credentials.arn
    DB_ENGINE     = "postgresql"
  }
  sensitive = true
}
