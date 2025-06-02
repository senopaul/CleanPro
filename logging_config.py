import os
import logging
import json
from datetime import datetime
from logging.handlers import RotatingFileHandler
from flask import request, g

class JSONFormatter(logging.Formatter):
    """
    Custom formatter that outputs logs in JSON format.
    """
    def format(self, record):
        log_record = {
            "timestamp": datetime.utcnow().isoformat(),
            "level": record.levelname,
            "message": record.getMessage(),
            "module": record.module,
            "function": record.funcName,
            "line": record.lineno
        }
        
        # Add request information if available
        if hasattr(g, 'request_id'):
            log_record["request_id"] = g.request_id
            
        if hasattr(record, 'path'):
            log_record["path"] = record.path
            
        if hasattr(record, 'method'):
            log_record["method"] = record.method
            
        if hasattr(record, 'remote_addr'):
            log_record["remote_addr"] = record.remote_addr
        
        # Add exception information if available
        if record.exc_info:
            log_record["exception"] = {
                "type": record.exc_info[0].__name__,
                "message": str(record.exc_info[1]),
                "traceback": self.formatException(record.exc_info)
            }
            
        # Add extra fields
        for key, value in record.__dict__.items():
            if key not in ['args', 'asctime', 'created', 'exc_info', 'exc_text', 
                          'filename', 'funcName', 'id', 'levelname', 'levelno', 
                          'lineno', 'module', 'msecs', 'message', 'msg', 'name', 
                          'pathname', 'process', 'processName', 'relativeCreated', 
                          'stack_info', 'thread', 'threadName']:
                try:
                    log_record[key] = value
                except (TypeError, ValueError):
                    log_record[key] = str(value)
                    
        return json.dumps(log_record)

def setup_logging(app, log_level=logging.INFO):
    """
    Set up application logging with both console and file handlers.
    
    Args:
        app: Flask application instance
        log_level: Logging level (default: INFO)
    """
    # Create logs directory if it doesn't exist
    log_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'logs')
    if not os.path.exists(log_dir):
        os.makedirs(log_dir)
    
    # Configure root logger
    root_logger = logging.getLogger()
    root_logger.setLevel(log_level)
    
    # Clear existing handlers
    for handler in root_logger.handlers[:]:
        root_logger.removeHandler(handler)
    
    # Console handler
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(JSONFormatter())
    root_logger.addHandler(console_handler)
    
    # File handler with rotation (10MB max file size, keep 10 backup files)
    file_handler = RotatingFileHandler(
        os.path.join(log_dir, 'cleanpro.log'),
        maxBytes=10*1024*1024,  # 10MB
        backupCount=10
    )
    file_handler.setFormatter(JSONFormatter())
    root_logger.addHandler(file_handler)
    
    # Set Flask logger to use the same configuration
    app.logger.handlers = root_logger.handlers
    app.logger.setLevel(log_level)
    
    # Add request logging
    @app.before_request
    def before_request():
        g.start_time = datetime.utcnow()
        g.request_id = request.headers.get('X-Request-ID', str(datetime.utcnow().timestamp()))

    @app.after_request
    def after_request(response):
        if hasattr(g, 'start_time'):
            duration = (datetime.utcnow() - g.start_time).total_seconds()
            app.logger.info(
                f"Request completed",
                extra={
                    'path': request.path,
                    'method': request.method,
                    'status_code': response.status_code,
                    'duration_seconds': duration,
                    'remote_addr': request.remote_addr,
                    'request_id': g.request_id
                }
            )
        return response
    
    # Log unhandled exceptions
    @app.errorhandler(Exception)
    def handle_exception(e):
        app.logger.error(
            f"Unhandled exception: {str(e)}",
            exc_info=True,
            extra={
                'path': request.path,
                'method': request.method,
                'remote_addr': request.remote_addr,
                'request_id': getattr(g, 'request_id', 'unknown')
            }
        )
        return jsonify({"error": "Internal server error"}), 500
    
    app.logger.info("Logging system initialized")
    return app.logger

