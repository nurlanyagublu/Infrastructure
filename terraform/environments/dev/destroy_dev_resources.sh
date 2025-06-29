#!/bin/bash

echo "Destroying existing dev2 resources..."

# Delete ECS resources
echo "Deleting ECS resources..."
aws ecs update-service --cluster nurlan-yagublu-dev2-cluster --service nurlan-yagublu-dev2-service --desired-count 0 2>/dev2/null || true
sleep 30
aws ecs delete-service --cluster nurlan-yagublu-dev2-cluster --service nurlan-yagublu-dev2-service 2>/dev2/null || true
aws ecs delete-cluster --cluster nurlan-yagublu-dev2-cluster 2>/dev2/null || true

# Delete RDS
echo "Deleting RDS..."
aws rds delete-db-instance --db-instance-identifier nurlan-yagublu-dev2-postgres --skip-final-snapshot 2>/dev2/null || true

# Delete ECR repository
echo "Deleting ECR..."
aws ecr delete-repository --repository-name nurlan-yagublu-dev2-flask-api --force 2>/dev2/null || true

# Delete secrets
echo "Deleting secrets..."
aws secretsmanager delete-secret --secret-id nurlan-yagublu-dev2-db-credentials --force-delete-without-recovery 2>/dev2/null || true

# Delete CloudWatch log groups
echo "Deleting CloudWatch logs..."
aws logs delete-log-group --log-group-name /ecs/nurlan-yagublu-dev2 2>/dev2/null || true

echo "Cleanup initiated. Some resources may take time to delete completely."
echo "Please wait a few minutes before proceeding with dev2 deployment."
