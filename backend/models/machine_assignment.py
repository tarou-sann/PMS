from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, Boolean
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from utils.formatters import format_id
from models import Base

class MachineAssignment(Base):
    __tablename__ = 'machine_assignments'

    id = Column(Integer, primary_key=True)
    machinery_id = Column(Integer, ForeignKey('machinery.id'), nullable=False)
    rentee_name = Column(String(100), nullable=False)
    start_hour_meter = Column(Integer, nullable=False)
    end_hour_meter = Column(Integer, nullable=True)
    assignment_date = Column(DateTime, default=func.now())
    return_date = Column(DateTime, nullable=True)
    is_active = Column(Boolean, default=True)
    notes = Column(String(500), nullable=True)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

    # Relationships
    machinery = relationship("Machinery", back_populates="assignments")

    def __init__(self, machinery_id, rentee_name, start_hour_meter, notes=None):
        self.machinery_id = machinery_id
        self.rentee_name = rentee_name
        self.start_hour_meter = start_hour_meter
        self.notes = notes

    def to_dict(self):
        return {
            'id': self.id,
            'formatted_id': format_id(self.id),
            'machinery_id': self.machinery_id,
            'machinery_name': self.machinery.machine_name if self.machinery else None,
            'rentee_name': self.rentee_name,
            'start_hour_meter': self.start_hour_meter,
            'end_hour_meter': self.end_hour_meter,
            'assignment_date': self.assignment_date.isoformat() if self.assignment_date else None,
            'return_date': self.return_date.isoformat() if self.return_date else None,
            'is_active': self.is_active,
            'notes': self.notes,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }