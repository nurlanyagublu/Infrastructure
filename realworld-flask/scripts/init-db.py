#!/usr/bin/env python3
"""
Database initialization script for production deployment
This script will be run during container startup to ensure database is ready
"""

import os
import sys
import time
import logging
from sqlalchemy import create_engine, text
from sqlalchemy.exc import SQLAlchemyError

# Add the parent directory to the path so we can import our modules
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from realworld.config import get_config

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def wait_for_database(max_retries=30, retry_delay=2):
    """Wait for database to be available"""
    config = get_config()
    
    for attempt in range(max_retries):
        try:
            engine = create_engine(config.DATABASE_URL)
            with engine.connect() as conn:
                conn.execute(text("SELECT 1"))
            logger.info("Database is available!")
            return True
        except SQLAlchemyError as e:
            logger.warning(f"Database not ready (attempt {attempt + 1}/{max_retries}): {e}")
            if attempt < max_retries - 1:
                time.sleep(retry_delay)
            else:
                logger.error("Database is not available after maximum retries")
                return False
    
    return False

def run_migrations():
    """Run database migrations using Alembic"""
    try:
        logger.info("Running database migrations...")
        os.system("alembic upgrade head")
        logger.info("Database migrations completed successfully")
        return True
    except Exception as e:
        logger.error(f"Database migration failed: {e}")
        return False

def main():
    """Main initialization function"""
    logger.info("Starting database initialization...")
    
    # Wait for database to be available
    if not wait_for_database():
        logger.error("Database initialization failed - database not available")
        sys.exit(1)
    
    # Run migrations
    if not run_migrations():
        logger.error("Database initialization failed - migrations failed")
        sys.exit(1)
    
    logger.info("Database initialization completed successfully")

if __name__ == "__main__":
    main()
