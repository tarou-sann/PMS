from functools import wraps
from flask import jsonify, request
from flask_jwt_extended import verify_jwt_in_request, get_jwt_identity
from models.user import User

def admin_required(fn):
    """
    Decorator to check if the current user is an admin.
    Must be used after the jwt_required decorator.
    """
    @wraps(fn)
    def wrapper(*args, **kwargs):
        verify_jwt_in_request()
        user_id = get_jwt_identity()
        user = User.query.filter_by(id=user_id).first()
        
        if not user or not user.is_admin:
            return jsonify({'message': 'Admin access required'}), 403
        
        return fn(*args, **kwargs)
    
    return wrapper