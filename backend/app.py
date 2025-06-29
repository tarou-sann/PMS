from flask import Flask, jsonify
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from flask_bcrypt import Bcrypt
from models import db_session, init_db, shutdown_session
from routes import api, init_routes
from config import Config
from routes.restore import restore_api
from routes.forecast import forecast_bp
from routes import auth, users, rice, production, machinery, repair, forecast, machine_assignments
import os
import argparse
from datetime import timedelta
import secrets

def get_persistent_jwt_secret():
    secret_file = os.path.join(os.path.dirname(__file__), 'jwt_secret.key')
    
    # If we have a saved secret key, use it
    if os.path.exists(secret_file):
        with open(secret_file, 'r') as f:
            return f.read().strip()
    
    # Otherwise generate a new one and save it
    secret = secrets.token_hex(32)
    with open(secret_file, 'w') as f:
        f.write(secret)
    
    return secret

# Initialize Flask app
app = Flask(__name__)
app.config.from_object(Config)

# Configure JWT with our persistent secret key
app.config['JWT_SECRET_KEY'] = get_persistent_jwt_secret()
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(hours=1)
app.config['JWT_REFRESH_TOKEN_EXPIRES'] = timedelta(days=30)

# Initialize Flask extensions
jwt = JWTManager(app)

@jwt.user_identity_loader
def user_identity_lookup(user):
    # Convert user ID to string before using it in the token
    return str(user)

bcrypt = Bcrypt(app)

# Enable CORS with more specific configuration
CORS(app, resources={
    r"/api/*": {
        "origins": ["http://localhost:*", "http://127.0.0.1:*", "http://10.0.2.2:*"],
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization"],
        "supports_credentials": True
    },
    r"/*": {
        "origins": ["http://localhost:*", "http://127.0.0.1:*", "http://10.0.2.2:*"],
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization"],
        "supports_credentials": True
    },
})

# Register blueprints
init_routes(app)

app.register_blueprint(restore_api, url_prefix='/api')
app.register_blueprint(forecast_bp, url_prefix='/api')

# Initialize database
@app.before_first_request
def setup_database():
    init_db()
    
    # Create admin user if it doesn't exist
    from models.user import User
    from sqlalchemy.exc import IntegrityError
    
    admin_username = os.environ.get('ADMIN_USERNAME', 'admin')
    admin_password = os.environ.get('ADMIN_PASSWORD', 'admin')
    
    try:
        admin = User.query.filter_by(username=admin_username).first()
        if not admin:
            admin = User(
                username=admin_username,
                password=admin_password,
                security_question="What is the default admin username?",
                security_answer="admin",
                is_admin=True
            )
            db_session.add(admin)
            db_session.commit()
            print(f"Admin user '{admin_username}' created.")
        else:
            print(f"Admin user '{admin_username}' already exists.")
    except IntegrityError:
        db_session.rollback()
        print(f"Error creating admin user.")


@app.route('/api')
def api_info():
    return jsonify({
        'message': 'PMS Backend API',
        'status': 'ok',
        'version': '1.0.0',
        'endpoints': {
            'health': '/api/health',
            'auth': {
                'login': '/api/auth/login',
                'signup': '/api/auth/signup',
                'register': '/api/auth/register'
            },
            'users': '/api/users',
            'machinery': '/api/machinery',
            'repairs': '/api/repairs',
            'production': '/api/production',
            'rice': '/api/rice',
            'assignments': '/api/assignments',
            'restore': '/api/restore',
            'forecast': '/api/forecast'
        }
    }), 200


@app.teardown_appcontext
def cleanup(exception=None):
    shutdown_session(exception)
    db_session.remove()

# JWT error handlers
@jwt.expired_token_loader
def expired_token_callback(jwt_header, jwt_payload):
    return jsonify({
        'message': 'Token has expired',
        'error': 'token_expired'
    }), 401

@jwt.invalid_token_loader
def invalid_token_callback(error_string):
    return jsonify({
        'message': f'Invalid token: {error_string}',
        'error': 'invalid_token'
    }), 401

@jwt.unauthorized_loader
def missing_token_callback(error_string):
    return jsonify({
        'message': f'Missing Authorization header: {error_string}',
        'error': 'missing_token'
    }), 401

# Root route for health check
@app.route('/')
def index():
    return jsonify({
        'message': 'PMS Backend API is running',
        'status': 'ok'
    })

@app.route('/api/health')
def health_check():
    return jsonify({
        'status': 'ok',
        'database_connected': True 
    })

if __name__ == '__main__':
    # Parse command line arguments
    parser = argparse.ArgumentParser(description='PMS Backend Server')
    parser.add_argument('--host', default='0.0.0.0', help='Host to bind to')
    parser.add_argument('--port', type=int, default=5000, help='Port to bind to')
    args = parser.parse_args()
    
    # Get host and port from environment variables if not provided as arguments
    host = os.environ.get('HOST', args.host)
    port = int(os.environ.get('PORT', args.port))
    
    # Run the Flask app
    app.run(host=host, port=port, debug=Config.DEBUG)