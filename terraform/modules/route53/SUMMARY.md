# Route 53 Module Summary

## Overview
DNS and SSL certificate management module for the nurlanskillup.pp.ua domain.

## Key Components

### 🌐 DNS Management
- **Hosted Zone**: `nurlanskillup.pp.ua`
- **A Records**: Point subdomains to Application Load Balancer
- **CNAME Records**: Optional www redirect to S3
- **Validation Records**: Automatic DNS validation for SSL certificates

### 🔒 SSL Certificates
- **ACM Certificate**: Covers root domain and wildcard (`*.nurlanskillup.pp.ua`)
- **DNS Validation**: Automated certificate validation
- **Auto-Renewal**: AWS handles certificate renewal

### 📊 Health Monitoring
- **Route 53 Health Checks**: Optional application monitoring
- **CloudWatch Integration**: Health check metrics and alarms

## Default Domain Structure
```
nurlanskillup.pp.ua           → ALB (configurable)
app.nurlanskillup.pp.ua       → ALB (main application)
api.nurlanskillup.pp.ua       → ALB (API endpoints)
www.nurlanskillup.pp.ua       → S3 (optional redirect)
```

## Module Dependencies
- **Input**: ALB DNS name and Zone ID from ECS module
- **Output**: Certificate ARN for ALB HTTPS listeners

## Post-Deployment Requirements
1. Update domain registrar with AWS name servers
2. Wait for DNS propagation (24-48 hours)
3. Configure ALB listeners to use the certificate ARN

## Files Structure
```
route53/
├── main.tf         # Route 53 resources and ACM certificate
├── variables.tf    # Input variables and configuration
├── outputs.tf      # Exported values for other modules
├── README.md       # Detailed documentation
└── SUMMARY.md      # This overview file
```

## Integration Points
- **ECS Module**: Uses ALB DNS name/zone for A records
- **S3 Module**: Optional www redirect to static website
- **Security Module**: Certificate ARN for HTTPS configuration

## Key Outputs
- `hosted_zone_name_servers`: For domain registrar configuration
- `certificate_arn`: For ALB HTTPS listeners
- `app_fqdn`, `api_fqdn`: Full domain names for application use
