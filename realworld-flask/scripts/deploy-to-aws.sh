#!/bin/bash
set -e

# AWS ECS Fargate Deployment Script for RealWorld Flask API

# Configuration
AWS_REGION=${AWS_REGION:-us-east-1}
AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID}
ECR_REPOSITORY_NAME=${ECR_REPOSITORY_NAME:-realworld-flask}
ECS_CLUSTER_NAME=${ECS_CLUSTER_NAME:-realworld-production}
ECS_SERVICE_NAME=${ECS_SERVICE_NAME:-realworld-flask-service}
IMAGE_TAG=${IMAGE_TAG:-latest}

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

check_requirements() {
    log_info "Checking requirements..."
    
    # Check if AWS CLI is installed
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed. Please install it first."
        exit 1
    fi
    
    # Check if required environment variables are set
    if [ -z "$AWS_ACCOUNT_ID" ]; then
        log_error "AWS_ACCOUNT_ID environment variable is not set"
        exit 1
    fi
    
    log_info "All requirements satisfied"
}

ecr_login() {
    log_info "Logging into ECR..."
    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
}

build_and_push_image() {
    log_info "Building Docker image..."
    
    # Build the image
    docker build -t $ECR_REPOSITORY_NAME:$IMAGE_TAG .
    
    # Tag for ECR
    ECR_URI=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPOSITORY_NAME:$IMAGE_TAG
    docker tag $ECR_REPOSITORY_NAME:$IMAGE_TAG $ECR_URI
    
    log_info "Pushing image to ECR: $ECR_URI"
    docker push $ECR_URI
    
    log_info "Image pushed successfully"
    echo "ECR_IMAGE_URI=$ECR_URI"
}

update_ecs_service() {
    log_info "Updating ECS service..."
    
    # Force new deployment
    aws ecs update-service \
        --cluster $ECS_CLUSTER_NAME \
        --service $ECS_SERVICE_NAME \
        --force-new-deployment \
        --region $AWS_REGION
    
    log_info "ECS service update initiated"
    
    # Wait for deployment to complete
    log_info "Waiting for deployment to complete..."
    aws ecs wait services-stable \
        --cluster $ECS_CLUSTER_NAME \
        --services $ECS_SERVICE_NAME \
        --region $AWS_REGION
    
    log_info "ECS service updated successfully"
}

check_deployment() {
    log_info "Checking deployment health..."
    
    # Get ALB DNS name from ECS service
    SERVICE_INFO=$(aws ecs describe-services \
        --cluster $ECS_CLUSTER_NAME \
        --services $ECS_SERVICE_NAME \
        --region $AWS_REGION \
        --query 'services[0].loadBalancers[0].targetGroupArn' \
        --output text)
    
    if [ "$SERVICE_INFO" != "None" ] && [ "$SERVICE_INFO" != "null" ]; then
        log_info "Service is running with load balancer"
        
        # Try to get ALB endpoint (this would need to be provided or looked up)
        if [ ! -z "$ALB_DNS_NAME" ]; then
            log_info "Testing health endpoint: https://$ALB_DNS_NAME/api/health"
            curl -f "https://$ALB_DNS_NAME/api/health" || log_warning "Health check endpoint not accessible yet"
        fi
    else
        log_warning "No load balancer found for service"
    fi
}

# Main deployment process
main() {
    log_info "Starting AWS ECS Fargate deployment for RealWorld Flask API"
    
    check_requirements
    ecr_login
    build_and_push_image
    update_ecs_service
    check_deployment
    
    log_info "Deployment completed successfully!"
    log_info "Your API should be available via the Application Load Balancer"
    log_info "Check the ECS console for detailed deployment status"
}

# Help function
show_help() {
    echo "AWS ECS Fargate Deployment Script for RealWorld Flask API"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Required Environment Variables:"
    echo "  AWS_ACCOUNT_ID      - Your AWS Account ID"
    echo ""
    echo "Optional Environment Variables:"
    echo "  AWS_REGION          - AWS Region (default: us-east-1)"
    echo "  ECR_REPOSITORY_NAME - ECR Repository Name (default: realworld-flask)"
    echo "  ECS_CLUSTER_NAME    - ECS Cluster Name (default: realworld-production)"
    echo "  ECS_SERVICE_NAME    - ECS Service Name (default: realworld-flask-service)"
    echo "  IMAGE_TAG           - Docker Image Tag (default: latest)"
    echo "  ALB_DNS_NAME        - ALB DNS Name for health check"
    echo ""
    echo "Example:"
    echo "  export AWS_ACCOUNT_ID=123456789012"
    echo "  export ALB_DNS_NAME=realworld-alb-123456789.us-east-1.elb.amazonaws.com"
    echo "  $0"
}

# Parse command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    *)
        main
        ;;
esac
