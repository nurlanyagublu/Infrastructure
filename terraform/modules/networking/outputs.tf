# ============================================================================
# NETWORKING MODULE OUTPUTS
# ============================================================================

# ============================================================================
# VPC Outputs
# ============================================================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

# ============================================================================
# Subnet Outputs
# ============================================================================

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_app_subnet_ids" {
  description = "IDs of the private application subnets"
  value       = aws_subnet.private_app[*].id
}

output "private_db_subnet_ids" {
  description = "IDs of the private database subnets"
  value       = aws_subnet.private_db[*].id
}

output "public_subnet_cidrs" {
  description = "CIDR blocks of the public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "private_app_subnet_cidrs" {
  description = "CIDR blocks of the private application subnets"
  value       = aws_subnet.private_app[*].cidr_block
}

output "private_db_subnet_cidrs" {
  description = "CIDR blocks of the private database subnets"
  value       = aws_subnet.private_db[*].cidr_block
}

# ============================================================================
# Route Table Outputs
# ============================================================================

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_app_route_table_ids" {
  description = "IDs of the private application route tables"
  value       = aws_route_table.private_app[*].id
}

output "private_db_route_table_id" {
  description = "ID of the private database route table"
  value       = aws_route_table.private_db.id
}

# ============================================================================
# NAT Gateway Outputs
# ============================================================================

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

output "nat_gateway_public_ips" {
  description = "Public IPs of the NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

# ============================================================================
# Security Group Outputs
# ============================================================================

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  description = "ID of the ECS security group"
  value       = aws_security_group.ecs.id
}

output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}

output "vpc_endpoints_security_group_id" {
  description = "ID of the VPC endpoints security group"
  value       = var.enable_vpc_endpoints ? aws_security_group.vpc_endpoints.id : null
}

output "bastion_security_group_id" {
  description = "ID of the bastion security group"
  value       = var.enable_bastion ? aws_security_group.bastion[0].id : null
}

# ============================================================================
# VPC Endpoint Outputs
# ============================================================================

output "s3_vpc_endpoint_id" {
  description = "ID of the S3 VPC endpoint"
  value       = var.enable_vpc_endpoints ? aws_vpc_endpoint.s3[0].id : null
}

output "ecr_api_vpc_endpoint_id" {
  description = "ID of the ECR API VPC endpoint"
  value       = var.enable_vpc_endpoints ? aws_vpc_endpoint.ecr_api[0].id : null
}

output "ecr_dkr_vpc_endpoint_id" {
  description = "ID of the ECR DKR VPC endpoint"
  value       = var.enable_vpc_endpoints ? aws_vpc_endpoint.ecr_dkr[0].id : null
}

output "logs_vpc_endpoint_id" {
  description = "ID of the CloudWatch Logs VPC endpoint"
  value       = var.enable_vpc_endpoints ? aws_vpc_endpoint.logs[0].id : null
}

output "secretsmanager_vpc_endpoint_id" {
  description = "ID of the Secrets Manager VPC endpoint"
  value       = var.enable_vpc_endpoints ? aws_vpc_endpoint.secretsmanager[0].id : null
}

# ============================================================================
# Availability Zone Outputs
# ============================================================================

output "availability_zones" {
  description = "List of availability zones used"
  value       = data.aws_availability_zones.available.names
}

# ============================================================================
# DB Subnet Group Name (for RDS module)
# ============================================================================

output "db_subnet_group_name" {
  description = "Name for RDS DB subnet group"
  value       = "${var.project_name}-db-subnet-group"
}
