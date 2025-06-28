from sqlalchemy import Column, Integer, String, Date, DateTime, Float
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from models import Base
from datetime import date
from utils.formatters import format_id

class RiceVariety(Base):
    __tablename__ = 'rice_varieties'

    id = Column(Integer, primary_key=True)
    variety_name = Column(String(100), nullable=False)
    quality_grade = Column(String(50), nullable=False)
    expected_yield_per_hectare = Column(Float, nullable=True)  # This is the baseline expected yield for this variety
    production_date = Column(Date, nullable=True)
    expiration_date = Column(Date, nullable=True)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

    production_records = relationship("ProductionTracking", back_populates="rice_variety", cascade="all, delete-orphan")

    def __init__(self, variety_name, quality_grade, expected_yield_per_hectare=None, production_date=None, expiration_date=None):
        self.variety_name = variety_name
        self.quality_grade = quality_grade
        self.expected_yield_per_hectare = expected_yield_per_hectare
        self.production_date = production_date
        self.expiration_date = expiration_date

    def to_dict(self):
        return {
            'id': self.id,
            'formatted_id': format_id(self.id),
            'variety_name': self.variety_name,
            'quality_grade': self.quality_grade,
            'expected_yield_per_hectare': float(self.expected_yield_per_hectare) if self.expected_yield_per_hectare else None,
            'production_date': self.production_date.isoformat() if self.production_date else None,
            'expiration_date': self.expiration_date.isoformat() if self.expiration_date else None,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }