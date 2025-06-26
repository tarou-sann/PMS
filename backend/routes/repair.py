from flask import request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from routes import api
from models import db_session
from models.repair import Repair
from models.machinery import Machinery
from utils.security import admin_required
from datetime import datetime

@api.route('/repairs', methods=['POST'])
@jwt_required()
def create_repair():
    """
    Create a new repair order and set machinery repairs_needed to True
    """
    data = request.get_json()
    
    if not data or not data.get('machinery_id') or not data.get('issue_description'):
        return jsonify({'message': 'Machinery ID and issue description are required'}), 400
    
    try:
        # Verify machinery exists
        machinery = Machinery.query.get(data['machinery_id'])
        if not machinery:
            return jsonify({'message': 'Machinery not found'}), 404
        
        is_urgent = data.get('is_urgent', False)
        if isinstance(is_urgent, str):
            is_urgent = is_urgent.lower() == 'true'
        
        repair = Repair(
            machinery_id=data['machinery_id'],
            issue_description=data['issue_description'],
            status=data.get('status', 'pending'),
            assigned_to=data.get('assigned_to'),
            notes=data.get('notes'),
            is_urgent=is_urgent
        )
        
        db_session.add(repair)
        
        # Automatically set repairs_needed to True for the machinery
        machinery.repairs_needed = True
        
        db_session.commit()
        
        return jsonify({
            'message': 'Repair order created successfully',
            'repair': repair.to_dict()
        }), 201
    
    except Exception as e:
        db_session.rollback()
        return jsonify({'message': f'Error creating repair order: {str(e)}'}), 500

@api.route('/repairs', methods=['GET'])
@jwt_required()
def get_all_repairs():
    """
    Get all repair orders
    """
    try:
        repairs = Repair.query.all()
        return jsonify({
            'repairs': [repair.to_dict() for repair in repairs]
        }), 200
    
    except Exception as e:
        return jsonify({'message': f'Error retrieving repair orders: {str(e)}'}), 500

@api.route('/repairs/<int:repair_id>', methods=['GET'])
@jwt_required()
def get_repair(repair_id):
    """
    Get a specific repair order
    """
    try:
        repair = Repair.query.get(repair_id)
        if not repair:
            return jsonify({'message': 'Repair order not found'}), 404
            
        return jsonify(repair.to_dict()), 200
    
    except Exception as e:
        return jsonify({'message': f'Error retrieving repair order: {str(e)}'}), 500

@api.route('/repairs/<int:repair_id>', methods=['PUT'])
@jwt_required()
def update_repair(repair_id):
    """
    Update a repair order and manage machinery repairs_needed status
    """
    repair = Repair.query.get(repair_id)
    
    if not repair:
        return jsonify({'message': 'Repair order not found'}), 404
    
    data = request.get_json()
    
    try:
        machinery_id = repair.machinery_id
        
        if data.get('machinery_id'):
            # Verify machinery exists
            machinery = Machinery.query.get(data['machinery_id'])
            if not machinery:
                return jsonify({'message': 'Machinery not found'}), 404
            machinery_id = data['machinery_id']
            repair.machinery_id = data['machinery_id']
        
        if data.get('issue_description'):
            repair.issue_description = data['issue_description']
        
        if data.get('status'):
            old_status = repair.status
            repair.status = data['status']
            if data['status'] == 'completed' and not repair.completed_date:
                repair.completed_date = datetime.utcnow()
            
            # If repair is marked as completed, check if other repairs exist for this machine
            if data['status'] == 'completed' and old_status != 'completed':
                other_pending_repairs = Repair.query.filter(
                    Repair.machinery_id == machinery_id,
                    Repair.id != repair_id,
                    Repair.status.in_(['pending', 'in_progress'])
                ).count()
                
                # If no other pending repairs, set repairs_needed to False
                if other_pending_repairs == 0:
                    machinery = Machinery.query.get(machinery_id)
                    if machinery:
                        machinery.repairs_needed = False
        
        if data.get('assigned_to') is not None:
            repair.assigned_to = data['assigned_to']
        
        if data.get('notes') is not None:
            repair.notes = data['notes']
        
        if 'is_urgent' in data:
            is_urgent = data['is_urgent']
            if isinstance(is_urgent, str):
                is_urgent = is_urgent.lower() == 'true'
            repair.is_urgent = is_urgent
        
        db_session.commit()
        
        return jsonify({
            'message': 'Repair order updated successfully',
            'repair': repair.to_dict()
        }), 200
    
    except Exception as e:
        db_session.rollback()
        return jsonify({'message': f'Error updating repair order: {str(e)}'}), 500

@api.route('/repairs/<int:repair_id>', methods=['DELETE'])
@jwt_required()
@admin_required
def delete_repair(repair_id):
    """
    Delete a repair order (admin only)
    """
    repair = Repair.query.get(repair_id)
    
    if not repair:
        return jsonify({'message': 'Repair order not found'}), 404
    
    try:
        db_session.delete(repair)
        db_session.commit()
        
        return jsonify({
            'message': 'Repair order deleted successfully'
        }), 200
    
    except Exception as e:
        db_session.rollback()
        return jsonify({'message': f'Error deleting repair order: {str(e)}'}), 500