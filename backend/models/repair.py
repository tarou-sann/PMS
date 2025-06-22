from datetime import datetime
from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from models import Base
from utils.formatters import format_id

class Repair(Base):
    __tablename__ = 'repairs'
    
    id = Column(Integer, primary_key=True)
    machinery_id = Column(Integer, ForeignKey('machinery.id'), nullable=False)
    issue_description = Column(Text, nullable=False)
    repair_date = Column(DateTime, default=datetime.utcnow)
    status = Column(String(20), default='pending') # pending, in_progress, completed
    assigned_to = Column(String(100))
    completed_date = Column(DateTime, nullable=True)
    notes = Column(Text, nullable=True)
    is_urgent = Column(Boolean, default=False)
    
    # Relationship
    machinery = relationship("Machinery", back_populates="repairs")
    
    def __init__(self, machinery_id, issue_description, status='pending', 
                 assigned_to=None, notes=None, is_urgent=False):
        self.machinery_id = machinery_id
        self.issue_description = issue_description
        self.status = status
        self.assigned_to = assigned_to
        self.notes = notes
        self.is_urgent = is_urgent
        
    def to_dict(self):
        return {
            'id': self.id,
            'formatted_id': format_id(self.id),
            'machinery_id': self.machinery_id,
            'issue_description': self.issue_description,
            'repair_date': self.repair_date.isoformat() if self.repair_date else None,
            'status': self.status,
            'assigned_to': self.assigned_to,
            'completed_date': self.completed_date.isoformat() if self.completed_date else None,
            'notes': self.notes,
            'is_urgent': self.is_urgent,
            'machine_name': self.machinery.machine_name if self.machinery else None
        }