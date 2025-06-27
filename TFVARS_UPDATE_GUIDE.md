# 📋 terraform.tfvars Update Guide

## 📍 **Files Updated**

I've updated **both** of your terraform.tfvars files:

1. **Development**: `/root/infrastructure/terraform/environment/dev/terraform.tfvars`
2. **Production**: `/root/infrastructure/terraform/environment/prod/terraform.tfvars`

## 🔧 **What You Need to Change Before Deploy**

### 1. **Replace Your AWS Account ID**
In both files, replace `your-account-id` with your actual AWS Account ID:

```bash
# Find your AWS Account ID
aws sts get-caller-identity --query Account --output text

# Then update in both tfvars files:
# CHANGE THIS:
app_image = "your-account-id.dkr.ecr.us-east-1.amazonaws.com/nurlan-yagublu-dev-flask-api:latest"
flask_secret_arn = "arn:aws:secretsmanager:us-east-1:your-account-id:secret:nurlan-yagublu/dev/flask/secret-key"

# TO THIS (example with account 123456789012):
app_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/nurlan-yagublu-dev-flask-api:latest"
flask_secret_arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:nurlan-yagublu/dev/flask/secret-key"
```

### 2. **Update CORS Origins**
Replace the CloudFront domain placeholders with your actual domains:

**Development** (`dev/terraform.tfvars`):
```hcl
# CHANGE THIS:
cors_origins = "http://localhost:3000,http://localhost:4200,https://dev.nurlanskillup.pp.ua,https://d123456789.cloudfront.net"

# TO YOUR ACTUAL DEV DOMAINS:
cors_origins = "http://localhost:3000,http://localhost:4200,https://dev.nurlanskillup.pp.ua,https://d1a2b3c4d5e6f.cloudfront.net"
```

**Production** (`prod/terraform.tfvars`):
```hcl
# CHANGE THIS:
cors_origins = "https://nurlanskillup.pp.ua,https://www.nurlanskillup.pp.ua,https://your-cloudfront-domain.cloudfront.net"

# TO YOUR ACTUAL PROD DOMAINS:
cors_origins = "https://nurlanskillup.pp.ua,https://www.nurlanskillup.pp.ua,https://d9g8h7i6j5k4l.cloudfront.net"
```

## 🔐 **Create AWS Secrets Before Terraform Apply**

You need to create these secrets in AWS Secrets Manager **before** running terraform:

### **Development Secrets:**
```bash
# Flask secret key for development
aws secretsmanager create-secret \
  --name "nurlan-yagublu/dev/flask/secret-key" \
  --description "Flask secret key for development" \
  --secret-string "dev-super-secret-key-change-me-123456789"

# JWT secret key for development  
aws secretsmanager create-secret \
  --name "nurlan-yagublu/dev/jwt/secret-key" \
  --description "JWT secret key for development" \
  --secret-string "dev-jwt-secret-key-change-me-987654321"
```

### **Production Secrets:**
```bash
# Generate strong random secrets for production
FLASK_SECRET=$(openssl rand -base64 32)
JWT_SECRET=$(openssl rand -base64 32)

# Flask secret key for production
aws secretsmanager create-secret \
  --name "nurlan-yagublu/prod/flask/secret-key" \
  --description "Flask secret key for production" \
  --secret-string "$FLASK_SECRET"

# JWT secret key for production
aws secretsmanager create-secret \
  --name "nurlan-yagublu/prod/jwt/secret-key" \
  --description "JWT secret key for production" \
  --secret-string "$JWT_SECRET"
```

## 🎯 **Summary of Changes Made**

### **Both Development & Production Files:**
✅ **Added**: `app_port = 8080` (Flask port)
✅ **Added**: `flask_secret_arn` (Flask secret key from Secrets Manager)
✅ **Added**: `jwt_secret_arn` (JWT secret key from Secrets Manager)  
✅ **Added**: `cors_origins` (Allowed CORS origins for frontend)
✅ **Added**: `health_check_path = "/api/health"` (Flask health endpoint)
✅ **Updated**: `app_image` to point to ECR repository for Flask app
✅ **Removed**: Old nginx references

### **Environment-Specific Differences:**

| Setting | Development | Production |
|---------|-------------|------------|
| **CORS** | Permissive (includes localhost) | Strict (only production domains) |
| **Secrets** | `/nurlan-yagublu/dev/` prefix | `/nurlan-yagublu/prod/` prefix |
| **ECR Repo** | `nurlan-yagublu-dev-flask-api` | `nurlan-yagublu-prod-flask-api` |

## ✅ **Ready to Deploy**

After making the changes above:

1. **Deploy Development:**
   ```bash
   cd /root/infrastructure/terraform/environment/dev
   terraform init
   terraform plan
   terraform apply
   ```

2. **Deploy Production:**
   ```bash
   cd /root/infrastructure/terraform/environment/prod  
   terraform init
   terraform plan
   terraform apply
   ```

3. **Push Flask App to ECR:**
   ```bash
   cd /root/realworld-flask
   export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
   ./scripts/deploy-to-aws.sh
   ```

Your terraform.tfvars files are now ready for Flask deployment! 🚀
