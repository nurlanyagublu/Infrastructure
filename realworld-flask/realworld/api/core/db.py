import os
import logging
import typing as typ
from sqlalchemy import create_engine, text
from sqlalchemy.pool import QueuePool
from contextlib import contextmanager
from sqlalchemy.orm import sessionmaker
from sqlalchemy.orm.session import Session, Connection
from sqlalchemy.exc import SQLAlchemyError
import time

logger = logging.getLogger(__name__)

# Database configuration based on environment
def get_database_config():
    """Get database configuration based on environment"""
    environment = os.getenv('FLASK_ENV', 'production')
    
    config = {
        'pool_size': int(os.getenv('DB_POOL_SIZE', '10')),
        'max_overflow': int(os.getenv('DB_MAX_OVERFLOW', '20')),
        'pool_timeout': int(os.getenv('DB_POOL_TIMEOUT', '30')),
        'pool_recycle': int(os.getenv('DB_POOL_RECYCLE', '3600')),
        'echo': environment == 'development' and os.getenv('DB_ECHO', 'False').lower() == 'true'
    }
    
    return config

def get_database_url():
    """Get database URL with proper configuration"""
    db_host = os.getenv('POSTGRES_HOST', 'localhost')
    db_port = os.getenv('POSTGRES_PORT', '5432')
    db_name = os.getenv('POSTGRES_DB', 'realworlddb')
    db_user = os.getenv('POSTGRES_USER')
    db_password = os.getenv('POSTGRES_PASSWORD')
    
    if not all([db_user, db_password]):
        raise ValueError("Database credentials not provided. Check POSTGRES_USER and POSTGRES_PASSWORD environment variables.")
    
    return f"postgresql+psycopg2://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}"

# Initialize engine with proper configuration
db_config = get_database_config()
database_url = get_database_url()

_ENGINE = create_engine(
    database_url,
    poolclass=QueuePool,
    pool_size=db_config['pool_size'],
    max_overflow=db_config['max_overflow'],
    pool_timeout=db_config['pool_timeout'],
    pool_recycle=db_config['pool_recycle'],
    echo=db_config['echo'],
    # Connection arguments for better reliability
    connect_args={
        "connect_timeout": 10,
        "application_name": f"realworld-flask-{os.getenv('FLASK_ENV', 'production')}"
    }
)

_Session = sessionmaker(bind=_ENGINE)

def get_db():
    """Get database connection for health checks and simple queries"""
    return _ENGINE

def _create_db_connection() -> typ.Tuple[Session, Connection]:
    """Create a new database connection with retry logic."""
    max_retries = 3
    retry_delay = 1
    
    for attempt in range(max_retries):
        try:
            session = _Session()
            conn = session.connection()
            return session, conn
        except SQLAlchemyError as e:
            logger.warning(f"Database connection attempt {attempt + 1} failed: {e}")
            if attempt < max_retries - 1:
                time.sleep(retry_delay * (2 ** attempt))  # Exponential backoff
            else:
                logger.error("All database connection attempts failed")
                raise

@contextmanager
def get_db_connection():
    """Context manager for handling database transactions with proper error handling."""
    session = None
    try:
        session, conn = _create_db_connection()
        yield conn
        session.commit()
        logger.debug("Database transaction committed successfully")
        
    except SQLAlchemyError as e:
        logger.error(f"Database error occurred: {e}")
        if session:
            session.rollback()
            logger.debug("Database transaction rolled back")
        raise e
    except Exception as e:
        logger.error(f"Unexpected error occurred: {e}")
        if session:
            session.rollback()
            logger.debug("Database transaction rolled back due to unexpected error")
        raise e
    finally:
        if session:
            session.close()

def check_database_connection():
    """Check if database connection is healthy"""
    try:
        with get_db_connection() as conn:
            result = conn.execute(text("SELECT 1")).fetchone()
            return result is not None
    except Exception as e:
        logger.error(f"Database health check failed: {e}")
        return False

def get_database_info():
    """Get database connection information for monitoring"""
    try:
        with get_db_connection() as conn:
            result = conn.execute(text("SELECT version()")).fetchone()
            return {
                "status": "connected",
                "version": result[0] if result else "unknown",
                "pool_size": _ENGINE.pool.size(),
                "checked_out_connections": _ENGINE.pool.checkedout(),
                "overflow": _ENGINE.pool.overflow(),
                "database_name": os.getenv('POSTGRES_DB', 'realworlddb'),
                "host": os.getenv('POSTGRES_HOST', 'localhost')
            }
    except Exception as e:
        logger.error(f"Failed to get database info: {e}")
        return {
            "status": "error",
            "error": str(e),
            "database_name": os.getenv('POSTGRES_DB', 'realworlddb'),
            "host": os.getenv('POSTGRES_HOST', 'localhost')
        }
