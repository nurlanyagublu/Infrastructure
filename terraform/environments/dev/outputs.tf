# Networking Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.networking.private_app_subnet_ids
}

# Database Outputs
output "db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = module.database.db_instance_endpoint
}

output "db_instance_id" {
  description = "RDS instance ID"
  value       = module.database.db_instance_id
}

# ECS Outputs
output "ecs_ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = module.ecs.ecs_cluster_id
}

output "ecs_ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs.ecs_service_name
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.ecs.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the load balancer"
  value       = module.ecs.alb_zone_id
}

# S3 Outputs
output "s3_bucket_id" {
  description = "Name of the S3 bucket"
  value       = module.s3_static_website.bucket_id
}

output "s3_website_endpoint" {
  description = "Website endpoint for the S3 bucket"
  value       = module.s3_static_website.website_endpoint
}

# Route 53 Outputs
output "hosted_zone_id" {
  description = "Route 53 hosted zone ID"
  value       = module.route53.hosted_zone_id
}

output "app_fqdn" {
  description = "Application domain name"
  value       = module.route53.app_fqdn
}

output "api_fqdn" {
  description = "API domain name"
  value       = module.route53.api_fqdn
}

output "certificate_arn" {
  description = "ACM certificate ARN"
  value       = module.route53.certificate_arn
}

# Security Outputs
output "kms_key_arn" {
  description = "KMS key ARN"
  value       = module.security.kms_key_arn
}

output "ecs_task_execution_role_arn" {
  description = "ECS task execution role ARN"
  value       = module.security.ecs_task_execution_role_arn
}

output "ecs_task_role_arn" {
  description = "ECS task role ARN"
  value       = module.security.ecs_task_role_arn
}

output "cicd_role_arn" {
  description = "CI/CD role ARN for GitHub Actions"
  value       = module.security.cicd_role_arn
}

# Environment Info
output "environment" {
  description = "Environment name"
  value       = "dev"
}

output "region" {
  description = "AWS region"
  value       = var.aws_region
}

# ECR Outputs
output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = module.ecs.ecr_repository_url
}

output "ecr_repository_arn" {
  description = "ECR repository ARN"
  value       = module.ecs.ecr_repository_arn
}

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = module.ecs.ecr_repository_name
}

# CloudFront Outputs
output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.s3_static_website.cloudfront_distribution_id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.s3_static_website.cloudfront_domain_name
}

output "website_url" {
  description = "Website URL (CloudFront if enabled, otherwise S3)"
  value       = module.s3_static_website.website_url
}
