from sqlalchemy import Column, Integer, String, Float, Date, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from models import Base
from datetime import date

class ProductionTracking(Base):
    __tablename__ = 'production_tracking'

    id = Column(Integer, primary_key=True)
    rice_variety_id = Column(Integer, ForeignKey('rice_varieties.id'), nullable=False)
    hectares = Column(Float, nullable=False)
    quantity_harvested = Column(Float, nullable=False)
    harvest_date = Column(Date, nullable=False)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

    # Relationship
    rice_variety = relationship("RiceVariety", back_populates="production_records")

    def __init__(self, rice_variety_id, hectares, quantity_harvested, harvest_date):
        self.rice_variety_id = rice_variety_id
        self.hectares = hectares
        self.quantity_harvested = quantity_harvested
        self.harvest_date = harvest_date

    def to_dict(self):
        return {
            'id': self.id,
            'rice_variety_id': self.rice_variety_id,
            'rice_variety_name': self.rice_variety.variety_name if self.rice_variety else None,
            'hectares': self.hectares,
            'quantity_harvested': self.quantity_harvested,
            'yield_per_hectare': round(self.quantity_harvested / self.hectares, 2) if self.hectares > 0 else 0,
            'harvest_date': self.harvest_date.isoformat() if self.harvest_date else None,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }