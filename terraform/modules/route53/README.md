# Route 53 Module

This module creates and manages Route 53 DNS resources for the nurlanskillup.pp.ua domain.

## Features

- **Hosted Zone**: Creates Route 53 hosted zone for your domain
- **SSL Certificates**: Provisions ACM certificates with DNS validation
- **DNS Records**: Creates A records for application and API endpoints
- **Health Checks**: Optional Route 53 health checks for monitoring
- **Subdomain Support**: Configurable subdomains for different services

## Resources Created

- Route 53 hosted zone
- ACM certificate (with wildcard support)
- DNS validation records
- A records pointing to ALB
- Optional CNAME records for www redirect
- Optional health checks

## Usage

```hcl
module "route53" {
  source = "./modules/route53"

  project_name     = "skillup-platform"
  environment      = "prod"
  domain_name      = "nurlanskillup.pp.ua"
  app_subdomain    = "app"
  api_subdomain    = "api"
  
  # From ECS module outputs
  alb_dns_name     = module.ecs.alb_dns_name
  alb_zone_id      = module.ecs.alb_zone_id
  
  # Optional configurations
  enable_health_check = true
  health_check_path   = "/health"
  aws_region         = "us-east-1"
}
```

## Important Setup Notes

### Domain Configuration

Since you already own `nurlanskillup.pp.ua` through your domain registrar:

1. **After applying this module**, you'll get name servers from the Route 53 hosted zone
2. **Update your domain registrar** to use these AWS name servers
3. **Wait for DNS propagation** (can take up to 48 hours)

### Certificate Validation

The ACM certificate uses DNS validation:
- Validation records are automatically created in Route 53
- Certificate will be validated once DNS is properly configured
- Supports both root domain and wildcard (*.nurlanskillup.pp.ua)

### Subdomain Structure

Default configuration creates:
- `app.nurlanskillup.pp.ua` → Points to ALB (main application)
- `api.nurlanskillup.pp.ua` → Points to ALB (API endpoints)
- `nurlanskillup.pp.ua` → Can point to ALB or S3 (configurable)

## Outputs

- `hosted_zone_id`: Use for other AWS services
- `hosted_zone_name_servers`: Configure in your domain registrar
- `certificate_arn`: Use in ALB listeners for HTTPS
- `app_fqdn`, `api_fqdn`: Full domain names for your services

## Next Steps After Deployment

1. Copy the name servers from `hosted_zone_name_servers` output
2. Update your domain registrar (where you bought nurlanskillup.pp.ua) to use these name servers
3. Wait for DNS propagation
4. Update ALB listeners to use the certificate ARN for HTTPS
5. Test domain resolution and SSL certificate
