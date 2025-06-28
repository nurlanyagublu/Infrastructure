# Vue3 Frontend Deployment Guide for S3 + CloudFront

## 🏗️ **Architecture Overview**

```
Internet → Route 53 → CloudFront → S3 (Vue3 Static Files)
                          ↓
                     Backend API (ALB → ECS Fargate)
```

## 📋 **Why No Nginx?**

✅ **S3 + CloudFront** handles everything nginx would do:
- **Static file serving** → S3 handles this natively
- **Gzip compression** → CloudFront handles this
- **SSL/TLS** → CloudFront handles this  
- **Caching** → CloudFront handles this
- **SPA routing** → CloudFront error pages handle this

❌ **Nginx would be needed if:**
- Deploying to containers (ECS/Kubernetes)
- Self-hosted servers
- Need custom server-side logic

## 🚀 **Deployment Process**

### **Development Environment**
```bash
# Set environment variables
export S3_BUCKET_NAME=myapp-dev-frontend-bucket
export API_HOST=https://myapp-dev-alb-123456789.us-east-1.elb.amazonaws.com
export CLOUDFRONT_ID=E1A2B3C4D5E6F7  # Optional

# Deploy to development
cd /root/vue3-realworld-example-app
pnpm run deploy:dev
```

### **Production Environment**
```bash
# Set environment variables  
export S3_BUCKET_NAME=myapp-prod-frontend-bucket
export API_HOST=https://myapp-prod-alb-987654321.us-east-1.elb.amazonaws.com
export CLOUDFRONT_ID=E7F6E5D4C3B2A1  # Optional

# Deploy to production
cd /root/vue3-realworld-example-app
pnpm run deploy:prod
```

## 🔧 **Environment Configuration**

### **Development** (`.env.development`)
- **API**: Local backend or dev ALB
- **Debug**: Enabled
- **Dev tools**: Enabled
- **Logging**: Verbose

### **Production** (`.env.production`)  
- **API**: Production ALB
- **Debug**: Disabled
- **Dev tools**: Disabled
- **Logging**: Errors only

## 📦 **Build Process**

### **Local Development**
```bash
# Run dev server
pnpm dev

# Build for development
pnpm run build:dev

# Preview development build
pnpm run preview:dev
```

### **Production Builds**
```bash
# Build for production
pnpm run build:prod

# Preview production build  
pnpm run preview:prod
```

## 🌐 **S3 + CloudFront Setup**

### **S3 Bucket Configuration**
```json
{
  "bucketName": "myapp-frontend-bucket",
  "websiteHosting": true,
  "indexDocument": "index.html",
  "errorDocument": "index.html",
  "cors": {
    "allowedOrigins": ["*"],
    "allowedMethods": ["GET", "HEAD"],
    "allowedHeaders": ["*"]
  }
}
```

### **CloudFront Configuration**
```json
{
  "origins": [
    {
      "domainName": "myapp-frontend-bucket.s3.amazonaws.com",
      "originPath": "",
      "s3OriginConfig": {}
    }
  ],
  "defaultCacheBehavior": {
    "targetOriginId": "S3-myapp-frontend-bucket",
    "viewerProtocolPolicy": "redirect-to-https",
    "cachePolicyId": "optimized-for-spa"
  },
  "customErrorPages": [
    {
      "errorCode": 404,
      "responsePagePath": "/index.html",
      "responseCode": 200
    },
    {
      "errorCode": 403,
      "responsePagePath": "/index.html", 
      "responseCode": 200
    }
  ]
}
```

## 🔄 **CI/CD Integration**

### **GitHub Actions Example**
```yaml
name: Deploy Frontend
on:
  push:
    branches: [main, develop]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: 18
          
      - name: Install pnpm
        run: npm install -g pnpm
        
      - name: Install dependencies
        run: pnpm install --frozen-lockfile
        
      - name: Deploy to Development
        if: github.ref == 'refs/heads/develop'
        env:
          S3_BUCKET_NAME: ${{ secrets.DEV_S3_BUCKET }}
          API_HOST: ${{ secrets.DEV_API_HOST }}
          CLOUDFRONT_ID: ${{ secrets.DEV_CLOUDFRONT_ID }}
        run: pnpm run deploy:dev
        
      - name: Deploy to Production
        if: github.ref == 'refs/heads/main'
        env:
          S3_BUCKET_NAME: ${{ secrets.PROD_S3_BUCKET }}
          API_HOST: ${{ secrets.PROD_API_HOST }}
          CLOUDFRONT_ID: ${{ secrets.PROD_CLOUDFRONT_ID }}
        run: pnpm run deploy:prod
```

## 🐛 **Troubleshooting**

### **Common Issues**

1. **SPA Routing 404s**
   - ✅ Configure CloudFront error pages to return `index.html`
   - ✅ S3 error document should be `index.html`

2. **API CORS Errors**
   - ✅ Update backend CORS settings to include CloudFront domain
   - ✅ Check API endpoints in browser dev tools

3. **Build Fails**
   - ✅ Check environment variables are set correctly
   - ✅ Verify API_HOST is accessible

4. **CloudFront Cache Issues**
   - ✅ Invalidate CloudFront cache after deployment
   - ✅ Use versioned asset filenames

## 🎯 **Verification Checklist**

After deployment:
- [ ] Frontend loads at CloudFront URL
- [ ] SPA routing works (refresh on sub-routes)
- [ ] API calls work (check browser network tab)
- [ ] Environment variables correct for build
- [ ] Static assets cached properly
- [ ] SSL certificate valid

## 💰 **Cost Optimization**

**S3 + CloudFront vs Container:**
- ✅ **S3 + CloudFront**: ~$1-5/month for small apps
- ❌ **ECS Container**: ~$15-30/month minimum

**Why S3 + CloudFront wins:**
- Static files don't need compute resources
- Global CDN improves performance
- Auto-scaling built-in
- Zero server management

Your frontend is now optimized for AWS serverless deployment! 🚀
