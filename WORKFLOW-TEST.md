# 🧪 CI/CD Workflow Test

This PR tests our GitHub Actions workflows:

## Workflows That Should Trigger:
1. 🔒 **Security Scan** - Runs automatically on PR
2. 🏗️ **Terraform Plan** - Runs automatically on PR (if terraform files change)

## Manual Workflows Available:
3. 🚀 **Terraform Apply** - Manual trigger in Actions tab
4. 🐍 **Backend Deploy** - Manual trigger in Actions tab  
5. 🎨 **Frontend Deploy** - Manual trigger in Actions tab

## Test Information:
- **Created:** Sat Jun 28 06:46:21 PM CEST 2025
- **Branch:** test-workflows-pr
- **AWS Role:** arn:aws:iam::253650698585:role/nurlan-yagublu-dev-cicd
- **Expected:** Security scan should run automatically

## Expected Results:
✅ Security scan workflow should start automatically  
✅ No Terraform plan (no terraform files changed)  
✅ Manual workflows should be available in Actions tab  
✅ AWS OIDC authentication should work  

