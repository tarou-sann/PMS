from flask import request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from routes import api
from models import db_session
from models.user import User
from utils.security import admin_required
from sqlalchemy.exc import IntegrityError

@api.route('/users', methods=['POST'])
@jwt_required()
@admin_required
def create_user():
    """
    Create a new user (admin only)
    """
    data = request.get_json()
    
    # Validate required fields
    required_fields = ['username', 'password', 'email', 'security_question', 'security_answer']
    for field in required_fields:
        if not data.get(field):
            return jsonify({'message': f'Missing required field: {field}'}), 400
    
    try:
        # Create new user
        user = User(
            username=data['username'],
            password=data['password'],
            email=data['email'],
            security_question=data['security_question'],
            security_answer=data['security_answer'],
            is_admin=data.get('is_admin', False)
        )
        
        db_session.add(user)
        db_session.commit()
        
        return jsonify({
            'message': 'User created successfully',
            'user': user.to_dict()
        }), 201
    
    except IntegrityError:
        db_session.rollback()
        return jsonify({'message': 'Username or email already exists'}), 409
    
    except Exception as e:
        db_session.rollback()
        return jsonify({'message': f'Error creating user: {str(e)}'}), 500

@api.route('/users', methods=['GET'])
@jwt_required()
@admin_required
def get_users():
    """
    Get all users (admin only)
    """
    users = User.query.all()
    return jsonify({
        'users': [user.to_dict() for user in users]
    }), 200

@api.route('/users/<int:user_id>', methods=['GET'])
@jwt_required()
def get_user(user_id):
    """
    Get a specific user
    Users can only access their own information, admins can access any user
    """
    current_user_id = get_jwt_identity()
    current_user = User.query.filter_by(id=current_user_id).first()
    
    # Non-admins can only access their own information
    if not current_user.is_admin and current_user_id != user_id:
        return jsonify({'message': 'Access denied'}), 403
    
    user = User.query.filter_by(id=user_id).first()
    
    if not user:
        return jsonify({'message': 'User not found'}), 404
    
    return jsonify(user.to_dict()), 200

@api.route('/users/<int:user_id>', methods=['PUT'])
@jwt_required()
def update_user(user_id):
    """
    Update a user
    Users can only update their own information, admins can update any user
    """
    current_user_id = get_jwt_identity()
    current_user = User.query.filter_by(id=current_user_id).first()
    
    # Non-admins can only update their own information
    if not current_user.is_admin and current_user_id != user_id:
        return jsonify({'message': 'Access denied'}), 403
    
    user = User.query.filter_by(id=user_id).first()
    
    if not user:
        return jsonify({'message': 'User not found'}), 404
    
    data = request.get_json()
    
    try:
        # Update user fields
        if data.get('email'):
            user.email = data['email']
        
        if data.get('security_question'):
            user.security_question = data['security_question']
        
        if data.get('security_answer'):
            user.set_security_answer(data['security_answer'])
        
        if data.get('password'):
            user.set_password(data['password'])
        
        # Only admins can update admin status
        if current_user.is_admin and 'is_admin' in data:
            user.is_admin = data['is_admin']
        
        db_session.commit()
        
        return jsonify({
            'message': 'User updated successfully',
            'user': user.to_dict()
        }), 200
    
    except IntegrityError:
        db_session.rollback()
        return jsonify({'message': 'Email already exists'}), 409
    
    except Exception as e:
        db_session.rollback()
        return jsonify({'message': f'Error updating user: {str(e)}'}), 500

@api.route('/users/<int:user_id>', methods=['DELETE'])
@jwt_required()
@admin_required
def delete_user(user_id):
    """
    Delete a user (admin only)
    """
    current_user_id = get_jwt_identity()
    
    # Prevent deleting yourself
    if current_user_id == user_id:
        return jsonify({'message': 'Cannot delete your own account'}), 400
    
    user = User.query.filter_by(id=user_id).first()
    
    if not user:
        return jsonify({'message': 'User not found'}), 404
    
    try:
        db_session.delete(user)
        db_session.commit()
        
        return jsonify({
            'message': 'User deleted successfully'
        }), 200
    
    except Exception as e:
        db_session.rollback()
        return jsonify({'message': f'Error deleting user: {str(e)}'}), 500