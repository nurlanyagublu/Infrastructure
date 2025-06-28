#!/bin/bash
set -e

echo "Starting RealWorld Flask Application..."
echo "Environment: ${FLASK_ENV:-production}"

# Initialize database if needed
if [ "${FLASK_ENV}" = "production" ] || [ "${INIT_DB}" = "true" ]; then
    echo "Initializing database..."
    python scripts/init-db.py
fi

# Start the application
echo "Starting Flask application..."
exec python -m flask run
