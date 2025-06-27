# ============================================================================
# CLOUDWATCH MONITORING AND ALARMS
# ============================================================================

# ============================================================================
# CloudWatch Alarms for Database Monitoring
# ============================================================================

# CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "db_cpu" {
  count = var.create_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-db-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_description   = "This metric monitors db cpu utilization"
  alarm_actions       = var.alarm_sns_topic_arn != null ? [var.alarm_sns_topic_arn] : []

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-db-cpu-alarm"
    Type = "CloudWatchAlarm"
  })
}

# Database Connection Alarm
resource "aws_cloudwatch_metric_alarm" "db_connections" {
  count = var.create_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-db-connections"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.connection_alarm_threshold
  alarm_description   = "This metric monitors database connections"
  alarm_actions       = var.alarm_sns_topic_arn != null ? [var.alarm_sns_topic_arn] : []

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-db-connections-alarm"
    Type = "CloudWatchAlarm"
  })
}

# Free Storage Space Alarm
resource "aws_cloudwatch_metric_alarm" "db_free_storage" {
  count = var.create_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-db-free-storage"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.free_storage_alarm_threshold
  alarm_description   = "This metric monitors database free storage space"
  alarm_actions       = var.alarm_sns_topic_arn != null ? [var.alarm_sns_topic_arn] : []

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-db-storage-alarm"
    Type = "CloudWatchAlarm"
  })
}

# ============================================================================
# CloudWatch Dashboard
# ============================================================================

resource "aws_cloudwatch_dashboard" "db_dashboard" {
  count = var.create_cloudwatch_dashboard ? 1 : 0

  dashboard_name = "${var.project_name}-${var.environment}-database-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", aws_db_instance.main.id],
            [".", "DatabaseConnections", ".", "."],
            [".", "FreeStorageSpace", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "RDS PostgreSQL Metrics"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["AWS/RDS", "ReadLatency", "DBInstanceIdentifier", aws_db_instance.main.id],
            [".", "WriteLatency", ".", "."],
            [".", "ReadThroughput", ".", "."],
            [".", "WriteThroughput", ".", "."]
          ]
          view    = "timeSeries"
          stacked = false
          region  = data.aws_region.current.name
          title   = "Database Performance"
          period  = 300
        }
      }
    ]
  })
}

# Data source for current region
data "aws_region" "current" {}
