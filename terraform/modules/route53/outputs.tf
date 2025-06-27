output "hosted_zone_id" {
  description = "Route 53 hosted zone ID"
  value       = aws_route53_zone.main.zone_id
}

output "hosted_zone_name_servers" {
  description = "Name servers for the hosted zone"
  value       = aws_route53_zone.main.name_servers
}

output "domain_name" {
  description = "The domain name"
  value       = var.domain_name
}

output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.main.arn
}

output "certificate_status" {
  description = "Status of the ACM certificate"
  value       = aws_acm_certificate.main.status
}

output "certificate_domain_validation_options" {
  description = "Domain validation options for the certificate"
  value       = aws_acm_certificate.main.domain_validation_options
}

output "app_fqdn" {
  description = "FQDN for the application"
  value       = var.app_subdomain != "" ? "${var.app_subdomain}.${var.domain_name}" : var.domain_name
}

output "api_fqdn" {
  description = "FQDN for the API"
  value       = var.api_subdomain != "" ? "${var.api_subdomain}.${var.domain_name}" : (var.app_subdomain != "" ? "${var.app_subdomain}.${var.domain_name}" : var.domain_name)
}

output "www_fqdn" {
  description = "FQDN for www subdomain"
  value       = "www.${var.domain_name}"
}

output "health_check_id" {
  description = "Route 53 health check ID"
  value       = var.enable_health_check ? aws_route53_health_check.app[0].id : null
}
