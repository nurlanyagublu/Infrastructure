# Route 53 Hosted Zone
resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = {
    Name        = "${var.project_name}-hosted-zone"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ACM Certificate for the domain
resource "aws_acm_certificate" "main" {
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"

  tags = {
    Name        = "${var.project_name}-certificate"
    Environment = var.environment
    Project     = var.project_name
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Route 53 records for ACM certificate validation
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}

# ACM certificate validation
resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

  timeouts {
    create = "5m"
  }
}

# A record pointing to CloudFront or Application Load Balancer
resource "aws_route53_record" "app" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.app_subdomain != "" ? "${var.app_subdomain}.${var.domain_name}" : var.domain_name
  type    = "A"

  alias {
    name                   = var.use_cloudfront_for_app ? var.cloudfront_domain_name : var.alb_dns_name
    zone_id                = var.use_cloudfront_for_app ? var.cloudfront_zone_id : var.alb_zone_id
    evaluate_target_health = true
  }
}

# A record for API subdomain (if different from app)
resource "aws_route53_record" "api" {
  count   = var.api_subdomain != "" && var.api_subdomain != var.app_subdomain ? 1 : 0
  zone_id = aws_route53_zone.main.zone_id
  name    = "${var.api_subdomain}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

# CNAME record for S3 static website (www subdomain)
resource "aws_route53_record" "www" {
  count   = var.enable_www_redirect ? 1 : 0
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [var.s3_website_endpoint]
}

# Health check for the main application
resource "aws_route53_health_check" "app" {
  count                           = var.enable_health_check ? 1 : 0
  fqdn                           = var.app_subdomain != "" ? "${var.app_subdomain}.${var.domain_name}" : var.domain_name
  port                           = 443
  type                           = "HTTPS"
  resource_path                  = var.health_check_path
  failure_threshold              = 3
  request_interval               = 30

  tags = {
    Name        = "${var.project_name}-health-check"
    Environment = var.environment
    Project     = var.project_name
  }
}
