#!/bin/bash
set -e

# Frontend Build and Deploy Script for S3 + CloudFront

# Configuration
ENVIRONMENT=${1:-production}
AWS_REGION=${AWS_REGION:-us-east-1}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_help() {
    echo "Frontend Build and Deploy Script"
    echo ""
    echo "Usage: $0 [ENVIRONMENT]"
    echo ""
    echo "Environments:"
    echo "  dev         - Deploy to development S3 bucket"
    echo "  production  - Deploy to production S3 bucket"
    echo ""
    echo "Required Environment Variables:"
    echo "  S3_BUCKET_NAME     - S3 bucket name for deployment"
    echo "  CLOUDFRONT_ID      - CloudFront distribution ID (optional)"
    echo "  API_HOST           - Backend API host URL"
    echo ""
    echo "Example:"
    echo "  export S3_BUCKET_NAME=myapp-dev-frontend"
    echo "  export API_HOST=https://myapp-dev-alb-123.us-east-1.elb.amazonaws.com"
    echo "  $0 dev"
}

check_requirements() {
    log_info "Checking requirements..."
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check if pnpm is installed
    if ! command -v pnpm &> /dev/null; then
        log_error "pnpm is not installed. Installing..."
        npm install -g pnpm
    fi
    
    # Check required environment variables
    if [ -z "$S3_BUCKET_NAME" ]; then
        log_error "S3_BUCKET_NAME environment variable is not set"
        exit 1
    fi
    
    if [ -z "$API_HOST" ]; then
        log_error "API_HOST environment variable is not set"
        exit 1
    fi
    
    log_info "All requirements satisfied"
}

set_environment_variables() {
    log_info "Setting environment variables for $ENVIRONMENT..."
    
    case $ENVIRONMENT in
        "dev")
            export VITE_API_HOST=${API_HOST}
            export VITE_API_BASE_URL=${API_HOST}/api
            export VITE_APP_TITLE="RealWorld - Development"
            export VITE_DEBUG=true
            export VITE_LOG_LEVEL=debug
            export VITE_ENABLE_DEV_TOOLS=true
            ;;
        "production")
            export VITE_API_HOST=${API_HOST}
            export VITE_API_BASE_URL=${API_HOST}/api
            export VITE_APP_TITLE="RealWorld"
            export VITE_DEBUG=false
            export VITE_LOG_LEVEL=error
            export VITE_ENABLE_DEV_TOOLS=false
            ;;
        *)
            log_error "Unknown environment: $ENVIRONMENT"
            log_info "Supported environments: dev, production"
            exit 1
            ;;
    esac
    
    log_info "Environment variables set for $ENVIRONMENT"
}

build_application() {
    log_info "Installing dependencies..."
    pnpm install --frozen-lockfile
    
    log_info "Building application for $ENVIRONMENT..."
    pnpm build
    
    if [ ! -d "dist" ]; then
        log_error "Build failed - dist directory not found"
        exit 1
    fi
    
    log_info "Build completed successfully"
}

deploy_to_s3() {
    log_info "Deploying to S3 bucket: $S3_BUCKET_NAME"
    
    # Sync files to S3 with proper cache headers
    aws s3 sync dist/ s3://$S3_BUCKET_NAME \
        --delete \
        --cache-control "max-age=31536000" \
        --exclude "*.html" \
        --region $AWS_REGION
    
    # Upload HTML files with no-cache (for SPA routing)
    aws s3 sync dist/ s3://$S3_BUCKET_NAME \
        --cache-control "max-age=0, no-cache, no-store, must-revalidate" \
        --include "*.html" \
        --region $AWS_REGION
    
    log_info "Files uploaded to S3 successfully"
}

invalidate_cloudfront() {
    if [ ! -z "$CLOUDFRONT_ID" ]; then
        log_info "Invalidating CloudFront distribution: $CLOUDFRONT_ID"
        
        aws cloudfront create-invalidation \
            --distribution-id $CLOUDFRONT_ID \
            --paths "/*" \
            --region $AWS_REGION
        
        log_info "CloudFront invalidation initiated"
    else
        log_warning "CLOUDFRONT_ID not set, skipping CloudFront invalidation"
    fi
}

verify_deployment() {
    if [ ! -z "$CLOUDFRONT_ID" ]; then
        FRONTEND_URL="https://$CLOUDFRONT_ID.cloudfront.net"
    else
        FRONTEND_URL="http://$S3_BUCKET_NAME.s3-website-$AWS_REGION.amazonaws.com"
    fi
    
    log_info "Deployment completed!"
    log_info "Frontend URL: $FRONTEND_URL"
    log_info "API URL: $VITE_API_BASE_URL"
    
    # Basic health check
    if curl -s --head "$FRONTEND_URL" | head -n 1 | grep -q "200 OK"; then
        log_info "✅ Frontend is accessible"
    else
        log_warning "⚠️ Frontend may not be accessible yet (propagation delay)"
    fi
}

# Main execution
main() {
    case "${1:-}" in
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log_info "Starting frontend deployment for environment: $ENVIRONMENT"
            check_requirements
            set_environment_variables
            build_application
            deploy_to_s3
            invalidate_cloudfront
            verify_deployment
            ;;
    esac
}

main "$@"
