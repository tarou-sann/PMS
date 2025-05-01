from sqlalchemy import Column, Integer, String, Boolean, DateTime
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from models import Base

class Machinery(Base):
    __tablename__ = 'machinery'

    id = Column(Integer, primary_key=True)
    machine_name = Column(String(100), nullable=False)
    is_mobile = Column(Boolean, default=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

    repairs = relationship("Repair", back_populates="machinery", cascade="all, delete-orphan")

    def __init__(self, machine_name, is_mobile=True, is_active=True):
        self.machine_name = machine_name
        self.is_mobile = is_mobile
        self.is_active = is_active

    def to_dict(self):
        return {
            'id': self.id,
            'machine_name': self.machine_name,
            'is_mobile': self.is_mobile,
            'is_active': self.is_active,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }