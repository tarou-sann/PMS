from flask import request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from routes import api
from models import db_session
from models.user import User
from utils.security import admin_required
from sqlalchemy.exc import IntegrityError
from sqlalchemy import func  # Add this import for func.lower()

@api.route('/users', methods=['POST'])
@jwt_required()
@admin_required
def create_user():
    """
    Create a new user (admin only)
    """
    data = request.get_json()
    
    # Validate required fields
    if not data or not data.get('username') or not data.get('password') or not data.get('security_question') or not data.get('security_answer'):
        return jsonify({'message': 'Missing required fields'}), 400
    
    try:
        # Check if username exists
        existing_user = User.query.filter(func.lower(User.username) == data['username'].lower()).first()
        if existing_user:
            return jsonify({'message': 'Username already exists'}), 409
        
        # Debug print statement
        print(f"Attempting to create user: {data['username']}")
        
        # Create user with empty string for email (not NULL)
        try:
            # Try the direct approach first
            user = User(
                username=data['username'],
                password=data['password'],
                # email="",  # Empty string to satisfy NOT NULL constraint
                security_question=data['security_question'],
                security_answer=data['security_answer'],
                is_admin=bool(data.get('is_admin', False))  # Ensure boolean type
            )
        except TypeError as e:
            # If parameter mismatch, try the alternative approach
            print(f"TypeError in User creation: {e}")
            user = User(
                username=data['username'],
                password=data['password'],
                security_question=data['security_question'],
                security_answer=data['security_answer'],
                is_admin=bool(data.get('is_admin', False))
            )
            # user.email = ""  # Set email after creation
        
        db_session.add(user)
        db_session.commit()
        
        return jsonify({'message': 'User created successfully'}), 201
        
    except IntegrityError as ie:
        db_session.rollback()
        error_msg = str(ie)
        print(f"IntegrityError in user creation: {error_msg}")
        if "UNIQUE constraint" in error_msg:
            return jsonify({'message': 'Username already exists'}), 409
        else:
            return jsonify({'message': f'Database integrity error: {error_msg}'}), 400
    except Exception as e:
        db_session.rollback()
        print(f"ERROR in users: Error creating user: {str(e)}")
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
        # Update security question
        if data.get('security_question'):
            user.security_question = data['security_question']
        
        # Update security answer
        if data.get('security_answer'):
            user.set_security_answer(data['security_answer'])
        
        # Update password
        if data.get('password'):
            # Validate password strength
            password = data['password']
            if len(password) < 8:
                return jsonify({'message': 'Password must be at least 8 characters long'}), 400
            user.set_password(password)
        
        # Only admins can update admin status
        if current_user.is_admin and 'is_admin' in data:
            user.is_admin = data['is_admin']
        
        db_session.commit()
        
        return jsonify({
            'message': 'User updated successfully',
            'user': user.to_dict()
        }), 200
    
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