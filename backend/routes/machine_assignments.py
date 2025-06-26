from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models.machine_assignment import MachineAssignment
from models.machinery import Machinery
from models import db_session
from datetime import datetime
from utils.security import admin_required

api = Blueprint('machine_assignments', __name__)

@api.route('/assignments', methods=['GET'])
@jwt_required()
def get_assignments():
    """
    Get all machine assignments
    """
    try:
        assignments = MachineAssignment.query.all()
        return jsonify({
            'assignments': [assignment.to_dict() for assignment in assignments]
        }), 200
    
    except Exception as e:
        return jsonify({'message': f'Error fetching assignments: {str(e)}'}), 500

@api.route('/assignments/active', methods=['GET'])
@jwt_required()
def get_active_assignments():
    """
    Get all active machine assignments
    """
    try:
        assignments = MachineAssignment.query.filter_by(is_active=True).all()
        return jsonify({
            'assignments': [assignment.to_dict() for assignment in assignments]
        }), 200
    
    except Exception as e:
        return jsonify({'message': f'Error fetching active assignments: {str(e)}'}), 500

@api.route('/assignments', methods=['POST'])
@jwt_required()
@admin_required
def create_assignment():
    """
    Create a new machine assignment (admin only)
    """
    data = request.get_json()
    
    if not data or not data.get('machinery_id') or not data.get('rentee_name') or not data.get('start_hour_meter'):
        return jsonify({'message': 'Machinery ID, rentee name, and start hour meter are required'}), 400
    
    try:
        # Verify machinery exists and is available for assignment
        machinery = Machinery.query.get(data['machinery_id'])
        if not machinery:
            return jsonify({'message': 'Machinery not found'}), 404
        
        # Check if machinery is eligible (mobile and can harvest)
        if not machinery.is_mobile or not machinery.is_active:
            return jsonify({'message': 'Only mobile machines that can harvest can be assigned'}), 400
        
        # Check if machinery is already assigned
        existing_assignment = MachineAssignment.query.filter_by(
            machinery_id=data['machinery_id'],
            is_active=True
        ).first()
        
        if existing_assignment:
            return jsonify({'message': 'This machine is already assigned and in use'}), 400
        
        # Validate hour meter
        start_hour_meter = int(data['start_hour_meter'])
        if start_hour_meter < machinery.hour_meter:
            return jsonify({'message': f'Start hour meter ({start_hour_meter}) cannot be less than current meter ({machinery.hour_meter})'}), 400
        
        assignment = MachineAssignment(
            machinery_id=data['machinery_id'],
            rentee_name=data['rentee_name'],
            start_hour_meter=start_hour_meter,
            notes=data.get('notes')
        )
        
        db_session.add(assignment)
        
        # Update machinery hour meter
        machinery.hour_meter = start_hour_meter
        
        db_session.commit()
        
        return jsonify({
            'message': 'Machine assignment created successfully',
            'assignment': assignment.to_dict()
        }), 201
    
    except ValueError:
        return jsonify({'message': 'Invalid hour meter value'}), 400
    except Exception as e:
        db_session.rollback()
        return jsonify({'message': f'Error creating assignment: {str(e)}'}), 500

@api.route('/assignments/<int:assignment_id>/return', methods=['PUT'])
@jwt_required()
@admin_required
def return_assignment(assignment_id):
    """
    Return a machine assignment (admin only)
    """
    assignment = MachineAssignment.query.get(assignment_id)
    
    if not assignment:
        return jsonify({'message': 'Assignment not found'}), 404
    
    if not assignment.is_active:
        return jsonify({'message': 'Assignment is already returned'}), 400
    
    data = request.get_json()
    
    if not data or not data.get('end_hour_meter'):
        return jsonify({'message': 'End hour meter is required'}), 400
    
    try:
        end_hour_meter = int(data['end_hour_meter'])
        
        if end_hour_meter < assignment.start_hour_meter:
            return jsonify({'message': f'End hour meter ({end_hour_meter}) cannot be less than start meter ({assignment.start_hour_meter})'}), 400
        
        # Update assignment
        assignment.end_hour_meter = end_hour_meter
        assignment.return_date = datetime.utcnow()
        assignment.is_active = False
        if data.get('notes'):
            assignment.notes = data['notes']
        
        # Update machinery hour meter
        machinery = Machinery.query.get(assignment.machinery_id)
        if machinery:
            machinery.hour_meter = end_hour_meter
        
        db_session.commit()
        
        return jsonify({
            'message': 'Machine returned successfully',
            'assignment': assignment.to_dict()
        }), 200
    
    except ValueError:
        return jsonify({'message': 'Invalid hour meter value'}), 400
    except Exception as e:
        db_session.rollback()
        return jsonify({'message': f'Error returning assignment: {str(e)}'}), 500

@api.route('/assignments/<int:assignment_id>', methods=['DELETE'])
@jwt_required()
@admin_required
def delete_assignment(assignment_id):
    """
    Delete a machine assignment (admin only)
    """
    assignment = MachineAssignment.query.get(assignment_id)
    
    if not assignment:
        return jsonify({'message': 'Assignment not found'}), 404
    
    try:
        db_session.delete(assignment)
        db_session.commit()
        
        return jsonify({'message': 'Assignment deleted successfully'}), 200
    
    except Exception as e:
        db_session.rollback()
        return jsonify({'message': f'Error deleting assignment: {str(e)}'}), 500

@api.route('/machinery/available', methods=['GET'])
@jwt_required()
def get_available_machinery():
    """
    Get machinery available for assignment (mobile and can harvest, not currently assigned)
    """
    try:
        # Get all mobile machines that can harvest
        eligible_machinery = Machinery.query.filter_by(
            is_mobile=True,
            is_active=True
        ).all()
        
        # Filter out machines that are currently assigned
        available_machinery = []
        for machine in eligible_machinery:
            active_assignment = MachineAssignment.query.filter_by(
                machinery_id=machine.id,
                is_active=True
            ).first()
            
            if not active_assignment:
                available_machinery.append(machine.to_dict())
        
        return jsonify({
            'machinery': available_machinery
        }), 200
    
    except Exception as e:
        return jsonify({'message': f'Error fetching available machinery: {str(e)}'}), 500