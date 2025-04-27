from flask import request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity, create_access_token
from routes import api
from services.auth import AuthService
from models import db_session
from models.user import User

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
    
    # Generate a temporary token for password reset
    reset_token = create_access_token(identity=user.id, expires_delta=False)
    
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
    
    user_id = get_jwt_identity()
    success, error = AuthService.reset_password(user_id, data['password'])
    
    if not success:
        return jsonify({'message': error}), 400
    
    return jsonify({
        'message': 'Password reset successful'
    }), 200