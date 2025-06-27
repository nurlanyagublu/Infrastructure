# ============================================================================
# ECS MODULE OUTPUTS
# ============================================================================

# ============================================================================
# ECS Cluster Outputs
# ============================================================================

output "ecs_cluster_id" {
  description = "ECS cluster ID"
  value       = aws_ecs_cluster.main.id
}

output "ecs_cluster_arn" {
  description = "ECS cluster ARN"
  value       = aws_ecs_cluster.main.arn
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

# ============================================================================
# ECS Service Outputs
# ============================================================================

output "ecs_service_id" {
  description = "ECS service ID"
  value       = aws_ecs_service.app.id
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.app.name
}

output "ecs_service_arn" {
  description = "ECS service ARN"
  value       = aws_ecs_service.app.id
}

# ============================================================================
# Task Definition Outputs
# ============================================================================

output "task_definition_arn" {
  description = "ECS task definition ARN"
  value       = aws_ecs_task_definition.app.arn
}

output "task_definition_family" {
  description = "ECS task definition family"
  value       = aws_ecs_task_definition.app.family
}

output "task_definition_revision" {
  description = "ECS task definition revision"
  value       = aws_ecs_task_definition.app.revision
}

# ============================================================================
# Load Balancer Outputs
# ============================================================================

output "alb_arn" {
  description = "Application Load Balancer ARN"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Application Load Balancer hosted zone ID"
  value       = aws_lb.main.zone_id
}

output "alb_url" {
  description = "Application Load Balancer URL"
  value       = "http://${aws_lb.main.dns_name}"
}

output "alb_https_url" {
  description = "Application Load Balancer HTTPS URL"
  value       = var.enable_https ? "https://${aws_lb.main.dns_name}" : null
}

# ============================================================================
# Target Group Outputs
# ============================================================================

output "target_group_arn" {
  description = "ALB target group ARN"
  value       = aws_lb_target_group.app.arn
}

output "target_group_name" {
  description = "ALB target group name"
  value       = aws_lb_target_group.app.name
}

# ============================================================================
# ECR Repository Outputs
# ============================================================================

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_repository_arn" {
  description = "ECR repository ARN"
  value       = aws_ecr_repository.app.arn
}

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = aws_ecr_repository.app.name
}

# ============================================================================
# IAM Role Outputs
# ============================================================================

output "ecs_execution_role_arn" {
  description = "ECS execution role ARN"
  value       = aws_iam_role.ecs_execution_role.arn
}

output "ecs_task_role_arn" {
  description = "ECS task role ARN"
  value       = aws_iam_role.ecs_task_role.arn
}

# ============================================================================
# CloudWatch Outputs
# ============================================================================

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.app.name
}

output "cloudwatch_log_group_arn" {
  description = "CloudWatch log group ARN"
  value       = aws_cloudwatch_log_group.app.arn
}

# ============================================================================
# Auto Scaling Outputs
# ============================================================================

output "autoscaling_target_arn" {
  description = "Auto scaling target ARN"
  value       = var.enable_autoscaling ? aws_appautoscaling_target.ecs_target[0].arn : null
}

output "autoscaling_cpu_policy_arn" {
  description = "Auto scaling CPU policy ARN"
  value       = var.enable_autoscaling ? aws_appautoscaling_policy.ecs_policy_cpu[0].arn : null
}

output "autoscaling_memory_policy_arn" {
  description = "Auto scaling memory policy ARN"
  value       = var.enable_autoscaling ? aws_appautoscaling_policy.ecs_policy_memory[0].arn : null
}

# ============================================================================
# Service Discovery Outputs
# ============================================================================

output "service_discovery_namespace_id" {
  description = "Service discovery namespace ID"
  value       = var.enable_service_discovery ? aws_service_discovery_private_dns_namespace.main[0].id : null
}

output "service_discovery_service_arn" {
  description = "Service discovery service ARN"
  value       = var.enable_service_discovery ? aws_service_discovery_service.app[0].arn : null
}

output "service_discovery_dns_name" {
  description = "Service discovery DNS name"
  value       = var.enable_service_discovery ? "flask-api.${var.project_name}-${var.environment}.local" : null
}

# ============================================================================
# Deployment Information
# ============================================================================

output "deployment_info" {
  description = "Deployment information for CI/CD"
  value = {
    cluster_name           = aws_ecs_cluster.main.name
    service_name           = aws_ecs_service.app.name
    task_definition_family = aws_ecs_task_definition.app.family
    ecr_repository_url     = aws_ecr_repository.app.repository_url
    alb_dns_name           = aws_lb.main.dns_name
    target_group_arn       = aws_lb_target_group.app.arn
  }
}

# ============================================================================
# Application URLs
# ============================================================================

output "application_urls" {
  description = "Application access URLs"
  value = {
    load_balancer_http  = "http://${aws_lb.main.dns_name}"
    load_balancer_https = var.enable_https ? "https://${aws_lb.main.dns_name}" : null
    health_check        = "http://${aws_lb.main.dns_name}${var.health_check_path}"
    api_base            = "http://${aws_lb.main.dns_name}/api"
  }
}
