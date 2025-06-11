from flask import request, jsonify
from flask_jwt_extended import jwt_required
from routes import api
from models import db_session
from models.production import ProductionTracking
from models.rice import RiceVariety
from utils.security import admin_required
from datetime import datetime

@api.route('/production', methods=['POST'])
@jwt_required()
@admin_required
def create_production_record():
    """
    Create a new production tracking record (admin only)
    """
    data = request.get_json()
    
    # Validate required fields
    required_fields = ['rice_variety_id', 'hectares', 'quantity_harvested', 'harvest_date']
    for field in required_fields:
        if field not in data or data[field] is None:
            return jsonify({'message': f'Missing required field: {field}'}), 400
    
    try:
        # Validate rice variety exists
        rice_variety = RiceVariety.query.filter_by(id=data['rice_variety_id']).first()
        if not rice_variety:
            return jsonify({'message': 'Rice variety not found'}), 404
        
        # Validate numeric fields
        try:
            hectares = float(data['hectares'])
            quantity_harvested = float(data['quantity_harvested'])
            
            if hectares <= 0:
                return jsonify({'message': 'Hectares must be greater than 0'}), 400
            if quantity_harvested <= 0:
                return jsonify({'message': 'Quantity harvested must be greater than 0'}), 400
                
        except (ValueError, TypeError):
            return jsonify({'message': 'Hectares and quantity harvested must be valid numbers'}), 400
        
        # Parse harvest date
        try:
            harvest_date = datetime.strptime(data['harvest_date'], '%Y-%m-%d').date()
        except ValueError:
            return jsonify({'message': 'Invalid harvest date format. Use YYYY-MM-DD'}), 400
        
        production_record = ProductionTracking(
            rice_variety_id=data['rice_variety_id'],
            hectares=hectares,
            quantity_harvested=quantity_harvested,
            harvest_date=harvest_date
        )
        
        db_session.add(production_record)
        db_session.commit()
        
        return jsonify({
            'message': 'Production record created successfully',
            'production_record': production_record.to_dict()
        }), 201
    
    except Exception as e:
        db_session.rollback()
        return jsonify({'message': f'Error creating production record: {str(e)}'}), 500

@api.route('/production', methods=['GET'])
@jwt_required()
def get_all_production_records():
    """
    Get all production tracking records
    """
    try:
        production_records = ProductionTracking.query.order_by(ProductionTracking.harvest_date.desc()).all()
        
        return jsonify({
            'production_records': [record.to_dict() for record in production_records]
        }), 200
    
    except Exception as e:
        return jsonify({'message': f'Error fetching production records: {str(e)}'}), 500

@api.route('/production/<int:production_id>', methods=['GET'])
@jwt_required()
def get_production_record(production_id):
    """
    Get a specific production record
    """
    production_record = ProductionTracking.query.filter_by(id=production_id).first()
    
    if not production_record:
        return jsonify({'message': 'Production record not found'}), 404
    
    return jsonify(production_record.to_dict()), 200

@api.route('/production/<int:production_id>', methods=['PUT'])
@jwt_required()
@admin_required
def update_production_record(production_id):
    """
    Update a production record (admin only)
    """
    production_record = ProductionTracking.query.filter_by(id=production_id).first()
    
    if not production_record:
        return jsonify({'message': 'Production record not found'}), 404
    
    data = request.get_json()
    
    try:
        if 'rice_variety_id' in data:
            rice_variety = RiceVariety.query.filter_by(id=data['rice_variety_id']).first()
            if not rice_variety:
                return jsonify({'message': 'Rice variety not found'}), 404
            production_record.rice_variety_id = data['rice_variety_id']
        
        if 'hectares' in data:
            try:
                hectares = float(data['hectares'])
                if hectares <= 0:
                    return jsonify({'message': 'Hectares must be greater than 0'}), 400
                production_record.hectares = hectares
            except (ValueError, TypeError):
                return jsonify({'message': 'Hectares must be a valid number'}), 400
        
        if 'quantity_harvested' in data:
            try:
                quantity_harvested = float(data['quantity_harvested'])
                if quantity_harvested <= 0:
                    return jsonify({'message': 'Quantity harvested must be greater than 0'}), 400
                production_record.quantity_harvested = quantity_harvested
            except (ValueError, TypeError):
                return jsonify({'message': 'Quantity harvested must be a valid number'}), 400
        
        if 'harvest_date' in data:
            try:
                production_record.harvest_date = datetime.strptime(data['harvest_date'], '%Y-%m-%d').date()
            except ValueError:
                return jsonify({'message': 'Invalid harvest date format. Use YYYY-MM-DD'}), 400
        
        db_session.commit()
        
        return jsonify({
            'message': 'Production record updated successfully',
            'production_record': production_record.to_dict()
        }), 200
    
    except Exception as e:
        db_session.rollback()
        return jsonify({'message': f'Error updating production record: {str(e)}'}), 500

@api.route('/production/<int:production_id>', methods=['DELETE'])
@jwt_required()
@admin_required
def delete_production_record(production_id):
    """
    Delete a production record (admin only)
    """
    production_record = ProductionTracking.query.filter_by(id=production_id).first()
    
    if not production_record:
        return jsonify({'message': 'Production record not found'}), 404
    
    try:
        db_session.delete(production_record)
        db_session.commit()
        
        return jsonify({
            'message': 'Production record deleted successfully'
        }), 200
    
    except Exception as e:
        db_session.rollback()
        return jsonify({'message': f'Error deleting production record: {str(e)}'}), 500