from flask import request, jsonify
from flask_jwt_extended import jwt_required
from routes import api
from models import db_session
from models.rice import RiceVariety
from utils.security import admin_required
from datetime import datetime

@api.route('/rice', methods=['POST'])
@jwt_required()
@admin_required
def create_rice_variety():
    """
    Create a new rice variety (admin only)
    """
    data = request.get_json()
    
    # Validate required fields
    required_fields = ['variety_name', 'quality_grade', 'production_date', 'expiration_date']
    for field in required_fields:
        if not data.get(field):
            return jsonify({'message': f'Missing required field: {field}'}), 400
    
    try:
        # Parse dates
        try:
            production_date = datetime.strptime(data['production_date'], '%Y-%m-%d').date()
            expiration_date = datetime.strptime(data['expiration_date'], '%Y-%m-%d').date()
            
            # Validate expiration date is after production date
            if expiration_date <= production_date:
                return jsonify({'message': 'Expiration date must be after production date'}), 400
            
        except ValueError:
            return jsonify({'message': 'Invalid date format. Use YYYY-MM-DD'}), 400
        
        rice_variety = RiceVariety(
            variety_name=data['variety_name'],
            quality_grade=data['quality_grade'],
            production_date=production_date,
            expiration_date=expiration_date
        )
        
        db_session.add(rice_variety)
        db_session.commit()
        
        return jsonify({
            'message': 'Rice variety created successfully',
            'rice_variety': rice_variety.to_dict()
        }), 201
    
    except Exception as e:
        db_session.rollback()
        return jsonify({'message': f'Error creating rice variety: {str(e)}'}), 500

@api.route('/rice', methods=['GET'])
@jwt_required()
def get_all_rice_varieties():
    """
    Get all rice varieties
    """
    rice_varieties = RiceVariety.query.all()
    
    return jsonify({
        'rice_varieties': [variety.to_dict() for variety in rice_varieties]
    }), 200

@api.route('/rice/<int:rice_id>', methods=['GET'])
@jwt_required()
def get_rice_variety(rice_id):
    """
    Get a specific rice variety
    """
    rice_variety = RiceVariety.query.filter_by(id=rice_id).first()
    
    if not rice_variety:
        return jsonify({'message': 'Rice variety not found'}), 404
    
    return jsonify(rice_variety.to_dict()), 200

@api.route('/rice/<int:rice_id>', methods=['PUT'])
@jwt_required()
@admin_required
def update_rice_variety(rice_id):
    """
    Update a rice variety (admin only)
    """
    rice_variety = RiceVariety.query.filter_by(id=rice_id).first()
    
    if not rice_variety:
        return jsonify({'message': 'Rice variety not found'}), 404
    
    data = request.get_json()
    
    try:
        if data.get('variety_name'):
            rice_variety.variety_name = data['variety_name']
        
        if data.get('quality_grade'):
            rice_variety.quality_grade = data['quality_grade']
        
        # Parse and update dates if provided
        if data.get('production_date'):
            try:
                rice_variety.production_date = datetime.strptime(data['production_date'], '%Y-%m-%d').date()
            except ValueError:
                return jsonify({'message': 'Invalid production date format. Use YYYY-MM-DD'}), 400
        
        if data.get('expiration_date'):
            try:
                rice_variety.expiration_date = datetime.strptime(data['expiration_date'], '%Y-%m-%d').date()
            except ValueError:
                return jsonify({'message': 'Invalid expiration date format. Use YYYY-MM-DD'}), 400
        
        # Validate expiration date is after production date
        if rice_variety.expiration_date <= rice_variety.production_date:
            return jsonify({'message': 'Expiration date must be after production date'}), 400
        
        db_session.commit()
        
        return jsonify({
            'message': 'Rice variety updated successfully',
            'rice_variety': rice_variety.to_dict()
        }), 200
    
    except Exception as e:
        db_session.rollback()
        return jsonify({'message': f'Error updating rice variety: {str(e)}'}), 500

@api.route('/rice/<int:rice_id>', methods=['DELETE'])
@jwt_required()
@admin_required
def delete_rice_variety(rice_id):
    """
    Delete a rice variety (admin only)
    """
    rice_variety = RiceVariety.query.filter_by(id=rice_id).first()
    
    if not rice_variety:
        return jsonify({'message': 'Rice variety not found'}), 404
    
    try:
        db_session.delete(rice_variety)
        db_session.commit()
        
        return jsonify({
            'message': 'Rice variety deleted successfully'
        }), 200
    
    except Exception as e:
        db_session.rollback()
        return jsonify({'message': f'Error deleting rice variety: {str(e)}'}), 500