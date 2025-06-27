# S3 Static Website Hosting Module

This Terraform module creates an S3 bucket configured for static website hosting without CloudFront.

## Features

- S3 bucket with static website hosting configuration
- Configurable public access controls
- Server-side encryption with AES256
- Optional versioning
- Optional CORS configuration
- Optional lifecycle rules for cost optimization
- Optional routing rules for URL redirects
- Comprehensive tagging support

## Usage

### Basic Example

```hcl
module "static_website" {
  source = "./modules/s3-static-website"

  bucket_name            = "my-unique-website-bucket"
  enable_website_hosting = true
  enable_public_access   = true
  index_document         = "index.html"
  error_document         = "404.html"

  tags = {
    Environment = "production"
    Project     = "my-website"
  }
}
```

### Advanced Example with CORS and Lifecycle

```hcl
module "advanced_website" {
  source = "./modules/s3-static-website"

  bucket_name            = "my-advanced-website-bucket"
  enable_website_hosting = true
  enable_public_access   = true
  versioning_enabled     = true
  index_document         = "index.html"
  error_document         = "404.html"

  cors_rules = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "HEAD"]
      allowed_origins = ["https://example.com"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]

  lifecycle_rules = [
    {
      id     = "delete_old_versions"
      status = "Enabled"
      expiration = null
      noncurrent_version_expiration = {
        noncurrent_days = 30
      }
    }
  ]

  tags = {
    Environment = "production"
    Project     = "advanced-website"
  }
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket_name | Name of the S3 bucket for static website hosting | `string` | n/a | yes |
| enable_website_hosting | Enable static website hosting on the S3 bucket | `bool` | `true` | no |
| enable_public_access | Enable public access to the S3 bucket (required for public website hosting) | `bool` | `false` | no |
| index_document | Name of the index document for the website | `string` | `"index.html"` | no |
| error_document | Name of the error document for the website | `string` | `null` | no |
| versioning_enabled | Enable versioning on the S3 bucket | `bool` | `false` | no |
| tags | A map of tags to assign to the resources | `map(string)` | `{}` | no |
| cors_rules | List of CORS rules for the S3 bucket | `list(object)` | `[]` | no |
| lifecycle_rules | List of lifecycle rules for the S3 bucket | `list(object)` | `[]` | no |
| routing_rules | List of routing rules for website configuration | `list(object)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | The name of the bucket |
| bucket_arn | The ARN of the bucket |
| bucket_domain_name | The bucket domain name |
| bucket_regional_domain_name | The bucket region-specific domain name |
| website_endpoint | The website endpoint, if the bucket is configured with a website |
| website_domain | The domain of the website endpoint, if the bucket is configured with a website |
| hosted_zone_id | The Route 53 Hosted Zone ID for this bucket's region |
| bucket_website_url | The full website URL if website hosting is enabled |

## Important Notes

1. **Public Access**: To serve a public website, you must set `enable_public_access = true`. This will:
   - Allow public access to the bucket
   - Create a bucket policy for public read access to objects

2. **Bucket Naming**: S3 bucket names must be globally unique. Consider using a random suffix or your organization's domain name.

3. **HTTPS**: S3 static website hosting only supports HTTP. If you need HTTPS, consider using CloudFront with this module.

4. **Custom Domain**: To use a custom domain, you'll need to:
   - Configure Route 53 DNS records pointing to the S3 website endpoint
   - Consider using CloudFront for HTTPS support

5. **Content Upload**: This module only creates the bucket infrastructure. You'll need to upload your website content separately using:
   - AWS CLI: `aws s3 sync ./website s3://your-bucket-name`
   - Terraform aws_s3_object resources
   - CI/CD pipeline

## Security Considerations

- The module encrypts objects at rest using AES256
- Public access is disabled by default - must be explicitly enabled
- Consider implementing additional security measures like:
  - Bucket notifications for monitoring
  - CloudTrail logging
  - Access logging

## Cost Optimization

- Use lifecycle rules to automatically delete old object versions
- Consider transitioning objects to cheaper storage classes if appropriate
- Monitor usage with AWS Cost Explorer

## Examples

See the `example.tf` file in this module for complete working examples.
