from flask import request, jsonify
from flask_jwt_extended import jwt_required
from routes import api
from models import db_session
from models.machinery import Machinery
from utils.security import admin_required

@api.route('/machinery', methods=['POST'])
@jwt_required()
@admin_required
def create_machinery():
    """
    Create a new machinery (admin only)
    """
    data = request.get_json()
    
    if not data or not data.get('machine_name'):
        return jsonify({'message': 'Machine name is required'}), 400
    
    try:
        is_mobile = data.get('is_mobile', True)
        is_active = data.get('is_active', True)
        
        # Convert string values to boolean if necessary
        if isinstance(is_mobile, str):
            is_mobile = is_mobile.lower() == 'true'
        if isinstance(is_active, str):
            is_active = is_active.lower() == 'true'
        
        machinery = Machinery(
            machine_name=data['machine_name'], 
            is_mobile=is_mobile,
            is_active=is_active
        )
        
        db_session.add(machinery)
        db_session.commit()
        
        return jsonify({
            'message': 'Machinery created successfully',
            'machinery': machinery.to_dict()
        }), 201
    
    except Exception as e:
        db_session.rollback()
        return jsonify({'message': f'Error creating machinery: {str(e)}'}), 500

@api.route('/machinery', methods=['GET'])
@jwt_required()
def get_all_machinery():
    """
    Get all machinery
    """
    machinery_list = Machinery.query.all()
    
    return jsonify({
        'machinery': [machine.to_dict() for machine in machinery_list]
    }), 200

@api.route('/machinery/<int:machinery_id>', methods=['GET'])
@jwt_required()
def get_machinery(machinery_id):
    """
    Get a specific machinery
    """
    machinery = Machinery.query.filter_by(id=machinery_id).first()
    
    if not machinery:
        return jsonify({'message': 'Machinery not found'}), 404
    
    return jsonify(machinery.to_dict()), 200

@api.route('/machinery/<int:machinery_id>', methods=['PUT'])
@jwt_required()
@admin_required
def update_machinery(machinery_id):
    """
    Update a machinery (admin only)
    """
    machinery = Machinery.query.filter_by(id=machinery_id).first()
    
    if not machinery:
        return jsonify({'message': 'Machinery not found'}), 404
    
    data = request.get_json()
    
    try:
        if data.get('machine_name'):
            machinery.machine_name = data['machine_name']
        
        if 'is_mobile' in data:
            is_mobile = data['is_mobile']
            if isinstance(is_mobile, str):
                is_mobile = is_mobile.lower() == 'true'
            machinery.is_mobile = is_mobile
        
        if 'is_active' in data:
            is_active = data['is_active']
            if isinstance(is_active, str):
                is_active = is_active.lower() == 'true'
            machinery.is_active = is_active
        
        db_session.commit()
        
        return jsonify({
            'message': 'Machinery updated successfully',
            'machinery': machinery.to_dict()
        }), 200
    
    except Exception as e:
        db_session.rollback()
        return jsonify({'message': f'Error updating machinery: {str(e)}'}), 500

@api.route('/machinery/<int:machinery_id>', methods=['DELETE'])
@jwt_required()
@admin_required
def delete_machinery(machinery_id):
    """
    Delete a machinery (admin only)
    """
    machinery = Machinery.query.filter_by(id=machinery_id).first()
    
    if not machinery:
        return jsonify({'message': 'Machinery not found'}), 404
    
    try:
        db_session.delete(machinery)
        db_session.commit()
        
        return jsonify({
            'message': 'Machinery deleted successfully'
        }), 200
    
    except Exception as e:
        db_session.rollback()
        return jsonify({'message': f'Error deleting machinery: {str(e)}'}), 500