from flask_jwt_extended import create_access_token, create_refresh_token
from models import db_session
from models.user import User

class AuthService:
    @staticmethod
    def authenticate(username, password):
        """
        Authenticate a user with username and password.
        Returns (user, None) if authentication succeeds, or (None, error_message) if it fails.
        """
        user = User.query.filter_by(username=username).first()
        
        if not user:
            return None, "Invalid username or password"
        
        if not user.check_password(password):
            return None, "Invalid username or password"
        
        return user, None
    
    @staticmethod
    def generate_tokens(user_id):
        """
        Generate JWT access and refresh tokens for a user.
        """
        access_token = create_access_token(identity=user_id)
        refresh_token = create_refresh_token(identity=user_id)
        
        return {
            'access_token': access_token,
            'refresh_token': refresh_token
        }
    
    @staticmethod
    def verify_security_answer(username, answer):
        """
        Verify a user's security question answer for password recovery.
        """
        user = User.query.filter_by(username=username).first()
        
        if not user:
            return None, "User not found"
        
        if not user.check_security_answer(answer):
            return None, "Incorrect answer"
        
        return user, None
    
    @staticmethod
    def reset_password(user_id, new_password):
        """
        Reset a user's password.
        """
        user = User.query.filter_by(id=user_id).first()
        
        if not user:
            return False, "User not found"
        
        user.set_password(new_password)
        db_session.commit()
        
        return True, None