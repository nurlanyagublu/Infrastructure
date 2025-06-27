output "bucket_id" {
  description = "The name of the bucket"
  value       = aws_s3_bucket.website.id
}

output "bucket_arn" {
  description = "The ARN of the bucket"
  value       = aws_s3_bucket.website.arn
}

output "bucket_domain_name" {
  description = "The bucket domain name"
  value       = aws_s3_bucket.website.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The bucket region-specific domain name"
  value       = aws_s3_bucket.website.bucket_regional_domain_name
}

output "website_endpoint" {
  description = "The website endpoint, if the bucket is configured with a website"
  value       = var.enable_website_hosting ? aws_s3_bucket_website_configuration.website[0].website_endpoint : null
}

output "website_domain" {
  description = "The domain of the website endpoint, if the bucket is configured with a website"
  value       = var.enable_website_hosting ? aws_s3_bucket_website_configuration.website[0].website_domain : null
}

output "hosted_zone_id" {
  description = "The Route 53 Hosted Zone ID for this bucket's region"
  value       = aws_s3_bucket.website.hosted_zone_id
}

output "bucket_website_url" {
  description = "The full website URL if website hosting is enabled"
  value       = var.enable_website_hosting ? "http://${aws_s3_bucket_website_configuration.website[0].website_endpoint}" : null
}

# ============================================================================
# CloudFront Outputs
# ============================================================================

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.website[0].id : null
}

output "cloudfront_distribution_arn" {
  description = "CloudFront distribution ARN"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.website[0].arn : null
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.website[0].domain_name : null
}

output "cloudfront_hosted_zone_id" {
  description = "CloudFront distribution hosted zone ID"
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.website[0].hosted_zone_id : null
}

output "website_url" {
  description = "Website URL (CloudFront if enabled, otherwise S3)"
  value       = var.enable_cloudfront ? "https://${aws_cloudfront_distribution.website[0].domain_name}" : (var.enable_website_hosting ? aws_s3_bucket_website_configuration.website[0].website_endpoint : null)
}
