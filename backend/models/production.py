from sqlalchemy import Column, Integer, String, Float, Date, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from models import Base
from datetime import date
from utils.formatters import format_id

class ProductionTracking(Base):
    __tablename__ = 'production_tracking'

    id = Column(Integer, primary_key=True)
    rice_variety_id = Column(Integer, ForeignKey('rice_varieties.id'), nullable=False)
    hectares = Column(Float, nullable=False)
    quantity_harvested = Column(Float, nullable=False)
    harvest_date = Column(Date, nullable=False)
    farmer_name = Column(String(100), nullable=False) 
    municipality = Column(String(50), nullable=False) 
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())

    # Relationship
    rice_variety = relationship("RiceVariety", back_populates="production_records")

    def __init__(self, rice_variety_id, hectares, quantity_harvested, harvest_date, farmer_name, municipality):
        self.rice_variety_id = rice_variety_id
        self.hectares = hectares
        self.quantity_harvested = quantity_harvested
        self.harvest_date = harvest_date
        self.farmer_name = farmer_name  
        self.municipality = municipality  
        
    def to_dict(self):
        # Calculate actual yield per hectare with safety checks
        actual_yield_per_hectare = 0
        if self.hectares and self.hectares > 0 and self.quantity_harvested:
            actual_yield_per_hectare = round(self.quantity_harvested / self.hectares, 2)
        
        # Calculate predicted total yield (what we expected to harvest)
        predicted_total_yield = 0
        variety_expected_yield_per_ha = None
        
        if (self.rice_variety and 
            self.rice_variety.expected_yield_per_hectare and 
            self.hectares and self.hectares > 0):
            variety_expected_yield_per_ha = self.rice_variety.expected_yield_per_hectare
            predicted_total_yield = round(variety_expected_yield_per_ha * self.hectares, 2)
        
        # Calculate yield variance (how much actual differs from predicted)
        yield_variance = 0
        yield_variance_percentage = 0
        if predicted_total_yield > 0 and self.quantity_harvested:
            yield_variance = round(self.quantity_harvested - predicted_total_yield, 2)
            yield_variance_percentage = round((yield_variance / predicted_total_yield) * 100, 2)
        
        return {
            'id': self.id,
            'formatted_id': format_id(self.id),
            'rice_variety_id': self.rice_variety_id,
            'rice_variety_name': self.rice_variety.variety_name if self.rice_variety else None,
            'variety_expected_yield_per_hectare': float(variety_expected_yield_per_ha) if variety_expected_yield_per_ha else None,
            'hectares': float(self.hectares) if self.hectares else 0,
            'quantity_harvested': float(self.quantity_harvested) if self.quantity_harvested else 0,  # Actual harvest
            'actual_yield_per_hectare': actual_yield_per_hectare,  # Renamed for clarity
            'predicted_total_yield': predicted_total_yield,  # What we expected to harvest total
            'yield_variance': yield_variance,  # Difference between actual and predicted
            'yield_variance_percentage': yield_variance_percentage,  # Percentage difference
            'harvest_date': self.harvest_date.isoformat() if self.harvest_date else None,
            'farmer_name': self.farmer_name,
            'municipality': self.municipality,
            'created_at': self.created_at.isoformat() if self.created_at else None,
            'updated_at': self.updated_at.isoformat() if self.updated_at else None
        }