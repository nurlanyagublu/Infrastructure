# ============================================================================
# NETWORKING MODULE - VPC, Subnets, Gateways, and Routing
# ============================================================================

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Data source for current region
data "aws_region" "current" {}

# ============================================================================
# VPC Configuration
# ============================================================================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-vpc"
    Type = "VPC"
  })
}

# ============================================================================
# Internet Gateway
# ============================================================================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-igw"
    Type = "InternetGateway"
  })
}

# ============================================================================
# Public Subnets (for ALB, NAT Gateways)
# ============================================================================

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
    Type = "PublicSubnet"
    Tier = "Public"
    AZ   = data.aws_availability_zones.available.names[count.index]
  })
}

# ============================================================================
# Private Subnets (for ECS, Application Layer)
# ============================================================================

resource "aws_subnet" "private_app" {
  count = length(var.private_app_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_app_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-private-app-subnet-${count.index + 1}"
    Type = "PrivateSubnet"
    Tier = "Application"
    AZ   = data.aws_availability_zones.available.names[count.index]
  })
}

# ============================================================================
# Database Subnets (for RDS)
# ============================================================================

resource "aws_subnet" "private_db" {
  count = length(var.private_db_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_db_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-private-db-subnet-${count.index + 1}"
    Type = "PrivateSubnet"
    Tier = "Database"
    AZ   = data.aws_availability_zones.available.names[count.index]
  })
}

# ============================================================================
# Elastic IPs for NAT Gateways
# ============================================================================

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? length(var.public_subnet_cidrs) : 0

  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-nat-eip-${count.index + 1}"
    Type = "ElasticIP"
  })
}

# ============================================================================
# NAT Gateways (for private subnet internet access)
# ============================================================================

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? length(var.public_subnet_cidrs) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  depends_on    = [aws_internet_gateway.main]

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-nat-gateway-${count.index + 1}"
    Type = "NATGateway"
    AZ   = data.aws_availability_zones.available.names[count.index]
  })
}

# ============================================================================
# Route Tables
# ============================================================================

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-public-rt"
    Type = "RouteTable"
    Tier = "Public"
  })
}

# Private Route Tables for Application Subnets
resource "aws_route_table" "private_app" {
  count = var.enable_nat_gateway ? length(var.private_app_subnet_cidrs) : 1

  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[count.index].id
    }
  }

  tags = merge(var.common_tags, {
    Name = var.enable_nat_gateway ? "${var.project_name}-private-app-rt-${count.index + 1}" : "${var.project_name}-private-app-rt"
    Type = "RouteTable"
    Tier = "Application"
  })
}

# Private Route Table for Database Subnets
resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-private-db-rt"
    Type = "RouteTable"
    Tier = "Database"
  })
}

# ============================================================================
# Route Table Associations
# ============================================================================

# Public Subnet Associations
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private App Subnet Associations
resource "aws_route_table_association" "private_app" {
  count = length(var.private_app_subnet_cidrs)

  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = var.enable_nat_gateway ? aws_route_table.private_app[count.index].id : aws_route_table.private_app[0].id
}

# Private DB Subnet Associations
resource "aws_route_table_association" "private_db" {
  count = length(var.private_db_subnet_cidrs)

  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private_db.id
}

# ============================================================================
# VPC Endpoints (for cost optimization and security)
# ============================================================================

# S3 VPC Endpoint (Gateway endpoint - no cost)
resource "aws_vpc_endpoint" "s3" {
  count = var.enable_vpc_endpoints ? 1 : 0

  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = concat([aws_route_table.public.id], aws_route_table.private_app[*].id)

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-s3-endpoint"
    Type = "VPCEndpoint"
  })
}

# ECR API VPC Endpoint (Interface endpoint)
resource "aws_vpc_endpoint" "ecr_api" {
  count = var.enable_vpc_endpoints ? 1 : 0

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private_app[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-ecr-api-endpoint"
    Type = "VPCEndpoint"
  })
}

# ECR DKR VPC Endpoint (Interface endpoint)
resource "aws_vpc_endpoint" "ecr_dkr" {
  count = var.enable_vpc_endpoints ? 1 : 0

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private_app[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-ecr-dkr-endpoint"
    Type = "VPCEndpoint"
  })
}

# CloudWatch Logs VPC Endpoint
resource "aws_vpc_endpoint" "logs" {
  count = var.enable_vpc_endpoints ? 1 : 0

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private_app[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-logs-endpoint"
    Type = "VPCEndpoint"
  })
}

# Secrets Manager VPC Endpoint
resource "aws_vpc_endpoint" "secretsmanager" {
  count = var.enable_vpc_endpoints ? 1 : 0

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private_app[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-secretsmanager-endpoint"
    Type = "VPCEndpoint"
  })
}
