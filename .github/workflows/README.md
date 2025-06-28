# 🚀 CI/CD Pipelines for RealWorld App

This directory contains 5 GitHub Actions workflows that provide a complete CI/CD pipeline for our full-stack RealWorld application.

## 📋 Pipeline Overview

| Pipeline | Trigger | Purpose | Environment |
|----------|---------|---------|-------------|
| 🏗️ `terraform-plan.yml` | PRs | Validate infrastructure changes | N/A |
| 🚀 `terraform-apply.yml` | Main branch / Manual | Deploy infrastructure | dev/prod |
| 🐍 `backend-deploy.yml` | Main branch / Manual | Deploy Flask API | dev/prod |
| 🎨 `frontend-deploy.yml` | Main branch / Manual | Deploy Vue3 app | dev/prod |
| 🔒 `security-scan.yml` | PRs + Daily | Security & quality checks | N/A |

## 🔧 Setup Requirements

### 1. AWS IAM Role for GitHub Actions
Create an OIDC provider and IAM role with necessary permissions.

### 2. GitHub Secrets
- `AWS_ROLE_ARN`: ARN of the IAM role for GitHub Actions

### 3. GitHub Environments
- `dev` (auto-deploy on main branch)
- `prod` (manual approval required)

## 🎯 Quick Start

1. **First Time Setup:**
   ```bash
   # Deploy infrastructure
   gh workflow run terraform-apply.yml -f environment=dev
   
   # Deploy backend
   gh workflow run backend-deploy.yml -f environment=dev
   
   # Deploy frontend
   gh workflow run frontend-deploy.yml -f environment=dev
   ```

2. **Production Deployment:**
   ```bash
   # Requires manual approval
   gh workflow run terraform-apply.yml -f environment=prod
   gh workflow run backend-deploy.yml -f environment=prod
   gh workflow run frontend-deploy.yml -f environment=prod
   ```

## 🔄 How It Works

### Development Flow
1. Create PR → Security scans run automatically
2. Merge to main → Infrastructure deploys to dev (if changed)
3. Backend/Frontend deploy automatically to dev
4. Manual approval required for production

### Smart Triggering
- Only runs when relevant files change
- Separate pipelines for each component
- Environment-specific deployments

Ready to use! 🚀
