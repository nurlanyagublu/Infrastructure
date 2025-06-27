variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "domain_name" {
  description = "The domain name for the hosted zone"
  type        = string
  default     = "nurlanskillup.pp.ua"
}

variable "app_subdomain" {
  description = "Subdomain for the main application (empty for root domain)"
  type        = string
  default     = "app"
}

variable "api_subdomain" {
  description = "Subdomain for the API (empty to use same as app)"
  type        = string
  default     = "api"
}

variable "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  type        = string
}

variable "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  type        = string
}

variable "s3_website_endpoint" {
  description = "S3 website endpoint for www redirect"
  type        = string
  default     = ""
}

variable "enable_www_redirect" {
  description = "Enable www subdomain redirect to S3"
  type        = bool
  default     = false
}

variable "enable_health_check" {
  description = "Enable Route 53 health check"
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "Path for health check"
  type        = string
  default     = "/health"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Additional DNS records (optional)
variable "additional_records" {
  description = "Additional DNS records to create"
  type = list(object({
    name    = string
    type    = string
    ttl     = number
    records = list(string)
  }))
  default = []
}

# CloudFront Variables
variable "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  type        = string
  default     = ""
}

variable "cloudfront_zone_id" {
  description = "CloudFront distribution hosted zone ID"
  type        = string
  default     = ""
}

variable "use_cloudfront_for_app" {
  description = "Use CloudFront for the app subdomain instead of ALB"
  type        = bool
  default     = false
}
