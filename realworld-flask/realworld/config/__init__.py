import os
import json
import boto3
import logging
from abc import ABC, abstractmethod
from typing import Dict, Any

logger = logging.getLogger(__name__)

class Config(ABC):
    """Base configuration class"""
    
    # Flask Configuration
    SECRET_KEY = None  # Will be loaded from security module
    
    # Database Configuration
    POSTGRES_HOST = os.getenv('POSTGRES_HOST', 'localhost')
    POSTGRES_PORT = os.getenv('POSTGRES_PORT', '5432')
    POSTGRES_DB = os.getenv('POSTGRES_DB', 'realworlddb')
    POSTGRES_USER = os.getenv('POSTGRES_USER')
    POSTGRES_PASSWORD = os.getenv('POSTGRES_PASSWORD')
    
    # Database Pool Configuration
    DB_POOL_SIZE = int(os.getenv('DB_POOL_SIZE', '10'))
    DB_MAX_OVERFLOW = int(os.getenv('DB_MAX_OVERFLOW', '20'))
    DB_POOL_TIMEOUT = int(os.getenv('DB_POOL_TIMEOUT', '30'))
    DB_POOL_RECYCLE = int(os.getenv('DB_POOL_RECYCLE', '3600'))
    
    # JWT Configuration
    JWT_SECRET_KEY = None  # Will be loaded from security module
    JWT_ACCESS_TOKEN_EXPIRES = int(os.getenv('JWT_ACCESS_TOKEN_EXPIRES', '3600'))  # 1 hour
    
    # CORS Configuration
    CORS_ORIGINS = os.getenv('CORS_ORIGINS', '*').split(',')
    
    # Logging Configuration
    LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')
    
    # Application Configuration
    APP_NAME = os.getenv('APP_NAME', 'realworld-flask')
    APP_VERSION = os.getenv('APP_VERSION', '1.0.0')
    
    def __init__(self):
        # Load secrets from AWS Secrets Manager on initialization
        self._load_secrets()
    
    def _load_secrets(self):
        """Load secrets from AWS Secrets Manager"""
        try:
            # In ECS, secrets are injected as environment variables by the task definition
            # The security module secrets are available as SECRET_KEY and JWT_SECRET_KEY
            self.SECRET_KEY = os.getenv('SECRET_KEY')
            self.JWT_SECRET_KEY = os.getenv('JWT_SECRET_KEY')
            
            if not self.SECRET_KEY or not self.JWT_SECRET_KEY:
                # Fallback for local development - use default values
                logger.warning("Secrets not found in environment variables, using defaults for development")
                self.SECRET_KEY = os.getenv('SECRET_KEY', 'dev-secret-key-change-in-production')
                self.JWT_SECRET_KEY = os.getenv('JWT_SECRET_KEY', 'dev-jwt-secret-key')
            else:
                logger.info("Successfully loaded secrets from environment variables")
                
        except Exception as e:
            logger.error(f"Failed to load secrets: {e}")
            # Use development defaults as fallback
            self.SECRET_KEY = 'dev-secret-key-change-in-production'
            self.JWT_SECRET_KEY = 'dev-jwt-secret-key'
    
    @property
    @abstractmethod
    def DATABASE_URL(self) -> str:
        pass
    
    @abstractmethod
    def get_config_dict(self) -> Dict[str, Any]:
        pass

class DevelopmentConfig(Config):
    """Development environment configuration"""
    
    DEBUG = True
    TESTING = False
    
    # Development-specific settings
    DB_ECHO = os.getenv('DB_ECHO', 'True').lower() == 'true'
    LOG_LEVEL = os.getenv('LOG_LEVEL', 'DEBUG')
    
    # Allow all origins in development
    CORS_ORIGINS = ['*']
    
    @property
    def DATABASE_URL(self) -> str:
        return f"postgresql+psycopg2://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
    
    def get_config_dict(self) -> Dict[str, Any]:
        return {
            'environment': 'development',
            'debug': self.DEBUG,
            'database_host': self.POSTGRES_HOST,
            'log_level': self.LOG_LEVEL,
            'cors_origins': self.CORS_ORIGINS,
            'secrets_loaded': bool(self.SECRET_KEY and self.JWT_SECRET_KEY)
        }

class ProductionConfig(Config):
    """Production environment configuration"""
    
    DEBUG = False
    TESTING = False
    
    # Production-specific settings
    DB_ECHO = False
    LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')
    
    # Stricter CORS in production
    CORS_ORIGINS = os.getenv('CORS_ORIGINS', '').split(',') if os.getenv('CORS_ORIGINS') else []
    
    # Production database settings
    DB_POOL_SIZE = int(os.getenv('DB_POOL_SIZE', '20'))
    DB_MAX_OVERFLOW = int(os.getenv('DB_MAX_OVERFLOW', '40'))
    
    @property
    def DATABASE_URL(self) -> str:
        # For RDS, we might need SSL
        ssl_mode = os.getenv('DB_SSL_MODE', 'require')
        base_url = f"postgresql+psycopg2://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
        
        if ssl_mode != 'disable':
            base_url += f"?sslmode={ssl_mode}"
            
        return base_url
    
    def get_config_dict(self) -> Dict[str, Any]:
        return {
            'environment': 'production',
            'debug': self.DEBUG,
            'database_host': self.POSTGRES_HOST,
            'log_level': self.LOG_LEVEL,
            'cors_origins_count': len(self.CORS_ORIGINS),
            'pool_size': self.DB_POOL_SIZE,
            'secrets_loaded': bool(self.SECRET_KEY and self.JWT_SECRET_KEY)
        }

    def validate(self):
        """Validate production configuration"""
        required_vars = ['SECRET_KEY', 'JWT_SECRET_KEY', 'POSTGRES_USER', 'POSTGRES_PASSWORD']
        missing_vars = []
        
        for var in required_vars:
            if var in ['SECRET_KEY', 'JWT_SECRET_KEY']:
                # These are loaded via _load_secrets method
                if not getattr(self, var):
                    missing_vars.append(var)
            else:
                if not os.getenv(var):
                    missing_vars.append(var)
        
        if missing_vars:
            raise ValueError(f"Missing required environment variables for production: {missing_vars}")

def get_config() -> Config:
    """Get configuration based on environment"""
    env = os.getenv('FLASK_ENV', 'production').lower()
    
    if env == 'development':
        return DevelopmentConfig()
    elif env == 'production':
        config = ProductionConfig()
        config.validate()
        return config
    else:
        raise ValueError(f"Unknown environment: {env}")

# Global config instance
config = get_config()
