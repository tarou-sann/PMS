from sqlalchemy import Column, Integer, String, Date, DateTime
from sqlalchemy.sql import func
from models import Base
from datetime import date

class RiceVariety(Base):
    __tablename__ = 'rice_varieties'

    id = Column(Integer, primary_key=True)
    variety_name = Column(String(100), nullable=False)
    quality_grade = Column(String(50), nullable=False)
    production_date = Column(Date, nullable=False)
    expiration_date = Column(Date, nullable=False)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

    def __init__(self, variety_name, quality_grade, production_date, expiration_date):
        self.variety_name = variety_name
        self.quality_grade = quality_grade
        self.production_date = production_date
        self.expiration_date = expiration_date

    def to_dict(self):
        return {
            'id': self.id,
            'variety_name': self.variety_name,
            'quality_grade': self.quality_grade,
            'production_date': self.production_date.isoformat() if self.production_date else None,
            'expiration_date': self.expiration_date.isoformat() if self.expiration_date else None,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }