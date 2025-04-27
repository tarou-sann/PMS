from sqlalchemy import Column, Integer, String, Boolean, DateTime
from sqlalchemy.sql import func
from models import Base
from werkzeug.security import generate_password_hash, check_password_hash

class User(Base):
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True)
    username = Column(String(80), unique=True, nullable=False)
    password_hash = Column(String(256), nullable=False)
    email = Column(String(120), unique=True, nullable=False)
    security_question = Column(String(200), nullable=False)
    security_answer_hash = Column(String(256), nullable=False)
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
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)
        
    def set_security_answer(self, answer):
        self.security_answer_hash = generate_password_hash(answer.lower())
        
    def check_security_answer(self, answer):
        return check_password_hash(self.security_answer_hash, answer.lower())

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