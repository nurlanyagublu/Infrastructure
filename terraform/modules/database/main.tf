# ============================================================================
# DATABASE MODULE - RDS PostgreSQL with High Availability
# ============================================================================

# Random password for database
resource "random_password" "db_password" {
  length  = 32
  special = true
}

# ============================================================================
# Secrets Manager for Database Credentials
# ============================================================================

resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "${var.project_name}-${var.environment}-db-credentials"
  description = "Database credentials for ${var.project_name} ${var.environment}"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-db-credentials"
    Type = "DatabaseCredentials"
  })
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username               = "pgadmin"
    password = random_password.db_password.result
    host     = split(":", aws_db_instance.main.endpoint)[0]
    port     = aws_db_instance.main.port
    dbname   = var.db_name
    engine   = "postgres"
  })

  depends_on = [aws_db_instance.main]
}

# ============================================================================
# DB Subnet Group
# ============================================================================

resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.private_db_subnet_ids

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-db-subnet-group"
    Type = "DBSubnetGroup"
  })
}

# ============================================================================
# DB Parameter Group
# ============================================================================

resource "aws_db_parameter_group" "main" {
  family = "postgres15"
  name   = "${var.project_name}-${var.environment}-postgres-params"

  # Performance and connection parameters
  parameter {
    name         = "shared_preload_libraries"
    value        = "pg_stat_statements"
    apply_method = "pending-reboot"  # Static parameter requires restart
  }

  parameter {
    name         = "log_statement"
    value        = "all"
    apply_method = "immediate"
  }

  parameter {
    name         = "log_min_duration_statement"
    value        = "1000" # Log queries longer than 1 second
    apply_method = "immediate"
  }

  parameter {
    name         = "max_connections"
    value        = var.max_connections
    apply_method = "pending-reboot"  # Usually requires restart
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-postgres-params"
    Type = "DBParameterGroup"
  })
}

# ============================================================================
# RDS PostgreSQL Instance
# ============================================================================

resource "aws_db_instance" "main" {
  # Basic Configuration
  identifier     = "${var.project_name}-${var.environment}-postgres"
  engine         = "postgres"
  engine_version        = "15.8"
  instance_class = var.db_instance_class

  # Database Configuration
  db_name  = var.db_name
  username               = "pgadmin"
  password = random_password.db_password.result
  port     = 5432

  # Storage Configuration
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = true
  kms_key_id            = var.kms_key_id

  # Network Configuration
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_security_group_id]
  publicly_accessible    = false

  # High Availability & Backup
  multi_az                 = var.multi_az
  backup_retention_period  = var.backup_retention_period
  backup_window            = var.backup_window
  maintenance_window       = var.maintenance_window
  copy_tags_to_snapshot    = true
  delete_automated_backups = false

  # Parameter Group
  parameter_group_name = aws_db_parameter_group.main.name

  # Monitoring
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = var.monitoring_interval > 0 ? aws_iam_role.rds_enhanced_monitoring[0].arn : null
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  # Performance Insights
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

  # Deletion Protection
  deletion_protection       = var.deletion_protection
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.project_name}-${var.environment}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-postgres"
    Type = "Database"
  })

  depends_on = [aws_db_parameter_group.main]
}

# ============================================================================
# Enhanced Monitoring IAM Role
# ============================================================================

resource "aws_iam_role" "rds_enhanced_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0

  name = "${var.project_name}-${var.environment}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-rds-monitoring-role"
    Type = "IAMRole"
  })
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0

  role       = aws_iam_role.rds_enhanced_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# ============================================================================
# Read Replica (Optional for Production)
# ============================================================================

resource "aws_db_instance" "read_replica" {
  count = var.create_read_replica ? 1 : 0

  identifier = "${var.project_name}-${var.environment}-postgres-read-replica"

  # Replica Configuration
  replicate_source_db = aws_db_instance.main.identifier
  instance_class      = var.replica_instance_class

  # Storage (inherited from source)
  storage_encrypted = true

  # Network Configuration
  vpc_security_group_ids = [var.rds_security_group_id]
  publicly_accessible    = false

  # Monitoring (can be different from source)
  monitoring_interval = var.replica_monitoring_interval
  monitoring_role_arn = var.replica_monitoring_interval > 0 ? aws_iam_role.rds_enhanced_monitoring[0].arn : null

  # Performance Insights
  performance_insights_enabled = var.replica_performance_insights_enabled

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-postgres-read-replica"
    Type = "DatabaseReadReplica"
  })
}
