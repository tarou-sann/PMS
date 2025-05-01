from flask import request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity, create_access_token, get_jwt
from routes import api
from services.auth import AuthService
from models import db_session
from models.user import User
from datetime import timedelta

@api.route('/auth/login', methods=['POST'])
def login():
    """
    Authenticate a user and generate JWT tokens
    """
    data = request.get_json()
    
    if not data or not data.get('username') or not data.get('password'):
        return jsonify({'message': 'Missing username or password'}), 400
    
    user, error = AuthService.authenticate(data['username'], data['password'])
    
    if error:
        return jsonify({'message': error}), 401
    
    tokens = AuthService.generate_tokens(user.id)
    
    return jsonify({
        'message': 'Login successful',
        'user': user.to_dict(),
        'tokens': tokens
    }), 200

@api.route('/auth/refresh', methods=['POST'])
@jwt_required(refresh=True)
def refresh():
    """
    Generate a new access token using a refresh token
    """
    user_id = get_jwt_identity()
    access_token = create_access_token(identity=user_id)
    
    return jsonify({
        'access_token': access_token
    }), 200

@api.route('/auth/password-recovery/question', methods=['POST'])
def get_security_question():
    """
    Get a user's security question for password recovery
    """
    data = request.get_json()
    
    if not data or not data.get('username'):
        return jsonify({'message': 'Missing username'}), 400
    
    user = User.query.filter_by(username=data['username']).first()
    
    if not user:
        return jsonify({'message': 'User not found'}), 404
    
    return jsonify({
        'security_question': user.security_question
    }), 200

@api.route('/auth/password-recovery/verify', methods=['POST'])
def verify_security_answer():
    """
    Verify a user's security question answer
    """
    data = request.get_json()
    
    if not data or not data.get('username') or not data.get('answer'):
        return jsonify({'message': 'Missing username or answer'}), 400
    
    user, error = AuthService.verify_security_answer(data['username'], data['answer'])
    
    if error:
        return jsonify({'message': error}), 400
    
    # Fix: Convert user.id to string for JWT subject
    reset_token = create_access_token(
        identity=str(user.id),  # Convert to string
        expires_delta=timedelta(minutes=15),
        additional_claims={"type": "password_reset"}
    )
    
    # Optional debug
    try:
        from flask_jwt_extended import decode_token
        decoded = decode_token(reset_token)
        print(f"Generated token for user {user.id}, sub type: {type(decoded['sub'])}, value: {decoded['sub']}")
    except Exception as e:
        print(f"Token validation error: {e}")
    
    return jsonify({
        'message': 'Security answer verified',
        'reset_token': reset_token
    }), 200

@api.route('/auth/password-recovery/reset', methods=['POST'])
@jwt_required()
def reset_password():
    """
    Reset a user's password
    """
    data = request.get_json()
    
    if not data or not data.get('password'):
        return jsonify({'message': 'Missing password'}), 400
    
    # Get the user ID from the token (will be a string)
    user_id_str = get_jwt_identity()
    
    # Convert back to integer for database lookup
    try:
        user_id = int(user_id_str)
    except (ValueError, TypeError):
        return jsonify({'message': 'Invalid user ID in token'}), 400
    
    success, error = AuthService.reset_password(user_id, data['password'])
    
    if not success:
        return jsonify({'message': error}), 400
    
    return jsonify({
        'message': 'Password reset successful'
    }), 200

@api.route('/auth/debug-token', methods=['POST'])
def debug_token():
    """Temporary endpoint to debug token issues"""
    data = request.get_json()
    token = data.get('token')
    
    if not token:
        return jsonify({'error': 'No token provided'}), 400
    
    try:
        from flask_jwt_extended import decode_token
        decoded = decode_token(token)
        return jsonify({
            'valid': True,
            'identity': decoded.get('sub'),
            'expiry': decoded.get('exp'),
            'type': decoded.get('type', 'none')
        }), 200
    except Exception as e:
        return jsonify({
            'valid': False,
            'error': str(e)
        }), 400

@api.route('/auth/signup', methods=['POST'])
def signup():
    data = request.get_json()
    
    # Validate required fields - Remove email from required fields
    required_fields = ['username', 'password', 'security_question', 'security_answer']
    for field in required_fields:
        if not data.get(field):
            return jsonify({'message': f'Missing required field: {field}'}), 400
            
    # Rest of the function...
    
    # When creating User
    user = User(
        username=data['username'],
        password=data['password'],
        email=data.get('email', ''),  # Make email optional with default empty string
        security_question=data['security_question'],
        security_answer=data['security_answer']
    )