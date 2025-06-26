from sqlalchemy import Column, Integer, String, Boolean, DateTime
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from utils.formatters import format_id
from models import Base

class Machinery(Base):
    __tablename__ = 'machinery'

    id = Column(Integer, primary_key=True)
    machine_name = Column(String(100), nullable=False)
    is_mobile = Column(Boolean, default=True)
    is_active = Column(Boolean, default=True)
    hour_meter = Column(Integer, default=0)  # Add hour meter field
    repairs_needed = Column(Boolean, default=False)  # Add repairs needed field
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

    # Relationships
    repairs = relationship("Repair", back_populates="machinery", cascade="all, delete-orphan")
    assignments = relationship("MachineAssignment", back_populates="machinery", cascade="all, delete-orphan")

    def __init__(self, machine_name, is_mobile=True, is_active=True, hour_meter=0, repairs_needed=False):
        self.machine_name = machine_name
        self.is_mobile = is_mobile
        self.is_active = is_active
        self.hour_meter = hour_meter
        self.repairs_needed = repairs_needed

    def to_dict(self):
        return {
            'id': self.id,
            'formatted_id': format_id(self.id),
            'machine_name': self.machine_name,
            'is_mobile': self.is_mobile,
            'is_active': self.is_active,
            'hour_meter': self.hour_meter,
            'repairs_needed': self.repairs_needed,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }