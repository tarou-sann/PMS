from sqlalchemy import Column, Integer, String, Boolean, DateTime
from sqlalchemy.sql import func
from models import Base, db_session  # Import db_session here
from flask_bcrypt import generate_password_hash, check_password_hash

class User(Base):
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True)
    username = Column(String(50), unique=True, nullable=False)
    password_hash = Column(String(128), nullable=False)
    email = Column(String(100), unique=True, nullable=False)
    security_question = Column(String(200), nullable=False)
    security_answer_hash = Column(String(128), nullable=False)
    is_admin = Column(Boolean, default=False)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

    def __init__(self, username, password, email, security_question, security_answer, is_admin=False):
        self.username = username
        self.set_password(password)
        self.email = email
        self.security_question = security_question
        self.set_security_answer(security_answer)
        self.is_admin = is_admin

    def set_password(self, password):
        self.password_hash = generate_password_hash(password).decode('utf-8')

    def check_password(self, password):
        # First check if it's a bcrypt hash
        if self.password_hash.startswith('$2b$'):
            return check_password_hash(self.password_hash, password)
        else:
            # Legacy check using werkzeug's check_password_hash
            from werkzeug.security import check_password_hash as werkzeug_check
            is_valid = werkzeug_check(self.password_hash, password)
            
            # If valid, upgrade to bcrypt
            if is_valid:
                self.set_password(password)
                # No need to import db_session here since we imported it at the top
                db_session.commit()
                
            return is_valid
        
    def set_security_answer(self, answer):
        self.security_answer_hash = generate_password_hash(answer.lower()).decode('utf-8')
        
    def check_security_answer(self, answer):
        # First check if it's a bcrypt hash
        if self.security_answer_hash.startswith('$2b$'):
            return check_password_hash(self.security_answer_hash, answer.lower())
        else:
            # Legacy check using werkzeug's check_password_hash
            from werkzeug.security import check_password_hash as werkzeug_check
            is_valid = werkzeug_check(self.security_answer_hash, answer.lower())
            
            # If valid, upgrade to bcrypt
            if is_valid:
                self.set_security_answer(answer)
                # Use db_session imported at the top of the file
                db_session.commit()
                
            return is_valid

    def to_dict(self):
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email,
            'security_question': self.security_question,
            'is_admin': self.is_admin,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }