import os
import logging
from datetime import datetime
from flask import Flask, jsonify, request
from flask_cors import CORS
from pydantic import ValidationError
from realworld.config import get_config
from realworld.api.routes.v1.users.routes import users_blueprint
from realworld.api.routes.v1.profiles.routes import profiles_blueprint
from realworld.api.routes.v1.articles.routes import articles_blueprint, tags_blueprint

# Initialize configuration
config = get_config()

def create_app() -> Flask:
    app = Flask(__name__)
    
    # Configure Flask app
    app.config['SECRET_KEY'] = config.SECRET_KEY
    app.config['DEBUG'] = config.DEBUG if hasattr(config, 'DEBUG') else False
    
    # Configure CORS for CloudFront + S3 frontend
    CORS(app, 
         origins=config.CORS_ORIGINS,
         methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
         allow_headers=['Content-Type', 'Authorization', 'X-Requested-With'],
         expose_headers=['X-Total-Count'])
    
    _register_blueprints(app)
    _register_error_handlers(app)
    _configure_logging(app)
    
    return app

def _register_blueprints(app: Flask):
    """Register all application blueprints"""
    app.register_blueprint(articles_blueprint, url_prefix="/api")
    app.register_blueprint(users_blueprint, url_prefix="/api")
    app.register_blueprint(
        profiles_blueprint, url_prefix=f"/api{profiles_blueprint.url_prefix}"
    )
    app.register_blueprint(
        tags_blueprint, url_prefix=f"/api{tags_blueprint.url_prefix}"
    )

    @app.route("/api/ping")
    def ping():
        """Simple ping endpoint for basic connectivity checks"""
        return jsonify({
            "message": "pong",
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "environment": os.getenv("FLASK_ENV", "production"),
            "service": config.APP_NAME,
            "version": config.APP_VERSION
        })
    
    @app.route("/api/health")
    def health_check():
        """
        ALB Health check endpoint
        This is the primary endpoint used by Application Load Balancer
        Must return 200 for healthy instances
        """
        try:
            health_info = {
                "status": "healthy",
                "service": config.APP_NAME,
                "version": config.APP_VERSION,
                "environment": os.getenv("FLASK_ENV", "production"),
                "timestamp": datetime.utcnow().isoformat() + "Z",
                "container_id": os.getenv("HOSTNAME", "unknown"),
                "ecs_task_arn": os.getenv("ECS_TASK_ARN", "unknown")
            }
            
            return jsonify(health_info), 200
            
        except Exception as e:
            logging.error(f"Health check failed: {e}")
            return jsonify({
                "status": "unhealthy",
                "service": config.APP_NAME,
                "environment": os.getenv("FLASK_ENV", "production"),
                "error": str(e),
                "timestamp": datetime.utcnow().isoformat() + "Z"
            }), 503

    @app.route("/api/ready")
    def readiness_check():
        """
        Readiness check endpoint for ECS deployment
        Checks database connectivity and application readiness
        """
        try:
            from realworld.api.core.db import check_database_connection, get_database_info
            
            db_healthy = check_database_connection()
            db_info = get_database_info()
            
            if db_healthy:
                return jsonify({
                    "status": "ready",
                    "service": config.APP_NAME,
                    "environment": os.getenv("FLASK_ENV", "production"),
                    "timestamp": datetime.utcnow().isoformat() + "Z",
                    "container_id": os.getenv("HOSTNAME", "unknown"),
                    "checks": {
                        "database": db_info,
                        "application": "ready"
                    }
                }), 200
            else:
                return jsonify({
                    "status": "not_ready",
                    "service": config.APP_NAME,
                    "environment": os.getenv("FLASK_ENV", "production"),
                    "timestamp": datetime.utcnow().isoformat() + "Z",
                    "container_id": os.getenv("HOSTNAME", "unknown"),
                    "checks": {
                        "database": db_info,
                        "application": "database_unavailable"
                    }
                }), 503
                
        except Exception as e:
            logging.error(f"Readiness check failed: {e}")
            return jsonify({
                "status": "not_ready",
                "service": config.APP_NAME,
                "environment": os.getenv("FLASK_ENV", "production"),
                "error": str(e),
                "timestamp": datetime.utcnow().isoformat() + "Z",
                "container_id": os.getenv("HOSTNAME", "unknown")
            }), 503

    @app.route("/api/metrics")
    def metrics():
        """CloudWatch metrics endpoint for monitoring"""
        try:
            from realworld.api.core.db import get_database_info
            
            db_info = get_database_info()
            
            return jsonify({
                "service": config.APP_NAME,
                "environment": os.getenv("FLASK_ENV", "production"),
                "timestamp": datetime.utcnow().isoformat() + "Z",
                "container_id": os.getenv("HOSTNAME", "unknown"),
                "ecs_cluster": os.getenv("ECS_CLUSTER_NAME", "unknown"),
                "ecs_service": os.getenv("ECS_SERVICE_NAME", "unknown"),
                "metrics": {
                    "database": {
                        "pool_size": db_info.get("pool_size", 0),
                        "checked_out_connections": db_info.get("checked_out_connections", 0),
                        "overflow": db_info.get("overflow", 0),
                        "status": db_info.get("status", "unknown")
                    },
                    "application": {
                        "uptime": _get_uptime(),
                        "memory_usage": _get_memory_usage(),
                        "cpu_count": os.cpu_count()
                    }
                }
            }), 200
            
        except Exception as e:
            logging.error(f"Metrics collection failed: {e}")
            return jsonify({
                "error": "Metrics collection failed",
                "message": str(e),
                "timestamp": datetime.utcnow().isoformat() + "Z"
            }), 500

def _register_error_handlers(app: Flask):
    """Register application error handlers with ECS-friendly logging"""
    
    @app.errorhandler(ValidationError)
    def handle_validation_error(error):
        logging.warning(f"Validation error: {error.errors()}")
        response = jsonify({
            "error": "Validation error", 
            "messages": error.errors(),
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "request_id": _get_request_id()
        })
        response.status_code = 422
        return response

    @app.errorhandler(404)
    def not_found(error):
        logging.info(f"404 error for path: {request.path}")
        return jsonify({
            "error": "Not found",
            "path": request.path,
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "request_id": _get_request_id()
        }), 404

    @app.errorhandler(500)
    def internal_error(error):
        logging.error(f"Internal server error: {error}")
        return jsonify({
            "error": "Internal server error",
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "request_id": _get_request_id()
        }), 500

    @app.errorhandler(503)
    def service_unavailable(error):
        logging.error(f"Service unavailable: {error}")
        return jsonify({
            "error": "Service unavailable",
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "request_id": _get_request_id()
        }), 503

def _configure_logging(app: Flask):
    """Configure logging for ECS CloudWatch integration"""
    
    log_level = getattr(logging, config.LOG_LEVEL.upper(), logging.INFO)
    
    # ECS-friendly logging format (JSON-like for CloudWatch)
    log_format = '%(asctime)s [%(levelname)s] %(name)s: %(message)s'
    if not app.debug:
        # Structured logging for production/CloudWatch
        log_format = '{"timestamp": "%(asctime)s", "level": "%(levelname)s", "logger": "%(name)s", "message": "%(message)s", "container_id": "' + os.getenv("HOSTNAME", "unknown") + '"}'
    
    logging.basicConfig(
        level=log_level,
        format=log_format,
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    
    # Configure Flask app logger
    app.logger.setLevel(log_level)
    
    # Add request logging for ALB access logs correlation
    if not app.debug:
        @app.before_request
        def log_request_info():
            app.logger.info(f"Request: {request.method} {request.url} from {request.remote_addr}")
        
        @app.after_request
        def log_response_info(response):
            app.logger.info(f"Response: {response.status_code} for {request.method} {request.url}")
            return response

def _get_uptime():
    """Get application uptime (simplified for ECS)"""
    try:
        with open('/proc/uptime', 'r') as f:
            uptime_seconds = float(f.readline().split()[0])
        return f"{uptime_seconds:.2f} seconds"
    except:
        return "unknown"

def _get_memory_usage():
    """Get basic memory usage info"""
    try:
        import psutil
        memory = psutil.virtual_memory()
        return {
            "total": memory.total,
            "available": memory.available,
            "percent": memory.percent
        }
    except ImportError:
        return "psutil not available"
    except:
        return "unknown"

def _get_request_id():
    """Generate or extract request ID for tracing"""
    # In production, you might want to extract this from ALB headers
    return request.headers.get('X-Request-ID', 'unknown')

# Create the Flask application instance
app = create_app()

if __name__ == '__main__':
    port = int(os.getenv('FLASK_RUN_PORT', 8080))
    host = os.getenv('FLASK_RUN_HOST', '0.0.0.0')
    debug = app.config.get('DEBUG', False)
    
    logging.info(f"Starting Flask application on {host}:{port} (debug={debug})")
    app.run(host=host, port=port, debug=debug)
