# ============================================================================
# COST-OPTIMIZED DEMO ARCHITECTURE
# Total Cost: ~$28/month with HA and Scalability
# ============================================================================

# Cost-optimized networking (VPC endpoints only, no NAT Gateway)
module "networking_cost_optimized" {
  source = "./modules/networking"

  project_name = "realworld"
  environment  = "demo"

  # Network Configuration
  vpc_cidr                   = "10.0.0.0/16"
  public_subnet_cidrs        = ["10.0.1.0/24", "10.0.2.0/24"]
  private_app_subnet_cidrs   = ["10.0.11.0/24", "10.0.12.0/24"]
  private_db_subnet_cidrs    = ["10.0.21.0/24", "10.0.22.0/24"]

  # Cost optimization settings
  cost_optimized_mode = true          # Enable cost optimization
  enable_nat_gateway  = false         # No NAT Gateway ($0 vs $45/month)
  enable_vpc_endpoints = true         # Required when no NAT Gateway
  enable_bastion      = false         # Not needed for demo

  common_tags = {
    Project       = "realworld"
    Environment   = "demo"
    CostOptimized = "true"
    ManagedBy     = "terraform"
  }
}

# Cost-optimized database (Single-AZ RDS)
module "database_cost_optimized" {
  source = "./modules/database"

  project_name = "realworld"
  environment  = "demo"

  # Network Configuration
  private_db_subnet_ids = module.networking_cost_optimized.private_db_subnet_ids
  rds_security_group_id = module.networking_cost_optimized.rds_security_group_id

  # Cost optimization settings ($12/month)
  cost_optimized_mode = true
  db_instance_class   = "db.t3.micro"     # $12/month
  multi_az           = false              # Single-AZ (can upgrade later)
  backup_retention_period = 7            # Keep backups
  deletion_protection = false            # Allow deletion for demo
  
  # Minimal monitoring
  monitoring_interval           = 0      # Disable enhanced monitoring
  performance_insights_enabled = false  # Disable PI
  create_cloudwatch_alarms     = false  # Minimal alarms
  create_read_replica          = false  # No read replica

  common_tags = {
    Project       = "realworld"
    Environment   = "demo"
    CostOptimized = "true"
    ManagedBy     = "terraform"
  }
}

# Cost-optimized ECS (Single Fargate task with NLB)
module "ecs_cost_optimized" {
  source = "./modules/ECS"

  project_name = "realworld"
  environment  = "demo"

  # Network Configuration
  vpc_id                 = module.networking_cost_optimized.vpc_id
  public_subnet_ids      = module.networking_cost_optimized.public_subnet_ids
  private_app_subnet_ids = module.networking_cost_optimized.private_app_subnet_ids
  alb_security_group_id  = module.networking_cost_optimized.alb_security_group_id
  ecs_security_group_id  = module.networking_cost_optimized.ecs_security_group_id

  # Database Configuration
  db_credentials_secret_arn = module.database_cost_optimized.db_credentials_secret_arn

  # Cost optimization settings ($8/month)
  cost_optimized_mode = true
  task_cpu           = 256              # 0.25 vCPU
  task_memory        = 512              # 512 MB
  desired_count      = 1                # Single task
  enable_fargate_spot = true            # Use spot for savings
  
  # Use NLB instead of ALB ($8/month vs $16/month)
  use_nlb_instead_of_alb = true
  
  # Scalability (can scale when needed)
  enable_autoscaling       = true       # Keep scaling capability
  autoscaling_min_capacity = 1          # Minimum 1 task
  autoscaling_max_capacity = 5          # Scale up to 5 tasks
  autoscaling_cpu_target   = 80         # Higher threshold
  autoscaling_memory_target = 85        # Higher threshold

  # Minimal monitoring
  enable_container_insights    = false  # Save CloudWatch costs
  enable_cloudwatch_alarms     = false  # Basic monitoring
  enable_cloudwatch_dashboard  = false  # No dashboard
  log_retention_days          = 3       # Short retention

  common_tags = {
    Project       = "realworld"
    Environment   = "demo"
    CostOptimized = "true"
    ManagedBy     = "terraform"
  }
}

# ============================================================================
# OUTPUTS
# ============================================================================

output "cost_optimized_summary" {
  description = "Cost optimization summary"
  value = {
    estimated_monthly_cost = "$28"
    breakdown = {
      rds_postgres = "$12 (t3.micro, Single-AZ)"
      ecs_fargate  = "$8 (256 CPU, 512 MB, 1 task)"
      nlb          = "$8 (Network Load Balancer)"
      vpc_endpoints = "$0 (using existing)"
      total        = "$28/month"
    }
    high_availability = {
      database = "Single-AZ (can upgrade to Multi-AZ: +$12/month)"
      application = "Single task (auto-scales to 5 tasks)"
      load_balancer = "Multi-AZ Network Load Balancer"
    }
    scalability = {
      database = "Can upgrade instance class, add read replicas"
      application = "Auto-scales 1-5 tasks based on CPU/Memory"
      load_balancer = "Handles increased traffic automatically"
    }
  }
}

output "application_endpoints" {
  description = "Application access endpoints"
  value = {
    load_balancer_url = "http://${module.ecs_cost_optimized.alb_dns_name}"
    health_check_url  = "http://${module.ecs_cost_optimized.alb_dns_name}/health"
    api_base_url      = "http://${module.ecs_cost_optimized.alb_dns_name}/api"
  }
}

output "scaling_instructions" {
  description = "Instructions for scaling when needed"
  value = {
    upgrade_database_to_ha = "Set multi_az = true (adds $12/month)"
    scale_application = "Increase autoscaling_max_capacity or desired_count"
    upgrade_to_alb = "Set use_nlb_instead_of_alb = false (adds $8/month)"
    add_monitoring = "Set enable_cloudwatch_alarms = true"
  }
}
