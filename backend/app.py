from flask import Flask, jsonify
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from models import db_session, init_db, shutdown_session
from routes import api, init_routes
from config import Config
import os
import argparse

# Initialize Flask app
app = Flask(__name__)
app.config.from_object(Config)

# Initialize Flask extensions
jwt = JWTManager(app)
CORS(app, resources={r"/api/*": {"origins": "*"}})

# Register blueprints
init_routes(app)

# Initialize database
@app.before_first_request
def setup_database():
    init_db()
    
    # Create admin user if it doesn't exist
    from models.user import User
    from sqlalchemy.exc import IntegrityError
    
    admin_username = os.environ.get('ADMIN_USERNAME', 'admin')
    admin_password = os.environ.get('ADMIN_PASSWORD', 'admin')
    admin_email = os.environ.get('ADMIN_EMAIL', 'admin@example.com')
    
    try:
        admin = User.query.filter_by(username=admin_username).first()
        if not admin:
            admin = User(
                username=admin_username,
                password=admin_password,
                email=admin_email,
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

@app.teardown_appcontext
def cleanup(exception=None):
    shutdown_session(exception)

# JWT error handlers
@jwt.expired_token_loader
def expired_token_callback(jwt_header, jwt_payload):
    return jsonify({
        'message': 'The token has expired',
        'error': 'token_expired'
    }), 401

@jwt.invalid_token_loader
def invalid_token_callback(error):
    return jsonify({
        'message': 'Signature verification failed',
        'error': 'invalid_token'
    }), 401

@jwt.unauthorized_loader
def missing_token_callback(error):
    return jsonify({
        'message': 'Request does not contain an access token',
        'error': 'authorization_required'
    }), 401

# Root route for health check
@app.route('/')
def index():
    return jsonify({
        'message': 'PMS Backend API is running',
        'status': 'ok'
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