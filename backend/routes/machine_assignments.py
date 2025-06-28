from flask import request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from routes import api  
from models import db_session
from models.machine_assignment import MachineAssignment
from models.machinery import Machinery
from datetime import datetime
from utils.security import admin_required
from utils.formatters import format_id  # Add this import

# Remove the separate blueprint creation - use the main api blueprint
# All routes will be registered with the main api blueprint

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
    Get machinery available for assignment (mobile and active, not currently assigned)
    """
    try:
        print("Getting available machinery...")  # Debug log
        
        # Get all active machines
        eligible_machinery = Machinery.query.filter_by(
            is_active=True
        ).all()
        
        print(f"Found {len(eligible_machinery)} active machines")  # Debug log
        
        # Filter out machines that are currently assigned or need repairs
        available_machinery = []
        for machine in eligible_machinery:
            # Check if machine has active assignments
            active_assignment = MachineAssignment.query.filter_by(
                machinery_id=machine.id,
                is_active=True
            ).first()
            
            # Only include machines that are:
            # - Not currently assigned
            # - Don't need repairs
            # - Are mobile (for daily use assignments)
            if not active_assignment and not machine.repairs_needed and machine.is_mobile:
                available_machinery.append(machine.to_dict())
        
        print(f"Available machinery count: {len(available_machinery)}")  # Debug log
        
        return jsonify({
            'machinery': available_machinery,
            'count': len(available_machinery)
        }), 200
    
    except Exception as e:
        print(f"Error fetching available machinery: {str(e)}")  # Debug log
        return jsonify({
            'message': f'Error fetching available machinery: {str(e)}',
            'machinery': [],  # Return empty array instead of null
            'count': 0
        }), 500

@api.route('/assignments/recent', methods=['GET'])
@jwt_required()
def get_recently_used_machines():
    """
    Get recently completed machine assignments (last 30 days)
    """
    try:
        from datetime import datetime, timedelta
        
        # Get assignments completed in the last 30 days
        thirty_days_ago = datetime.now() - timedelta(days=30)
        
        recent_assignments = db_session.query(MachineAssignment).filter(
            MachineAssignment.is_active == False,  # Completed assignments
            MachineAssignment.return_date >= thirty_days_ago,  # Within last 30 days
            MachineAssignment.return_date.isnot(None)  # Must have a return date
        ).order_by(MachineAssignment.return_date.desc()).limit(10).all()
        
        # Get detailed information for each assignment
        assignments_data = []
        for assignment in recent_assignments:
            machinery = Machinery.query.filter_by(id=assignment.machinery_id).first()
            
            # Calculate hours used
            hours_used = 0
            if assignment.end_hour_meter and assignment.start_hour_meter:
                hours_used = assignment.end_hour_meter - assignment.start_hour_meter
            
            # Calculate days used
            days_used = 0
            if assignment.return_date and assignment.assignment_date:  # Fixed: use assignment_date not start_date
                days_used = (assignment.return_date - assignment.assignment_date).days + 1
            
            # Match the actual model fields - remove unnecessary/non-existent fields
            assignment_data = {
                'id': assignment.id,
                'formatted_id': format_id(assignment.id),  # Add this since it's in to_dict()
                'machinery_id': assignment.machinery_id,
                'machinery_name': machinery.machine_name if machinery else 'Unknown',
                'rentee_name': assignment.rentee_name,
                'start_hour_meter': assignment.start_hour_meter,
                'end_hour_meter': assignment.end_hour_meter,
                'assignment_date': assignment.assignment_date.isoformat() if assignment.assignment_date else None,  # Fixed: use assignment_date
                'return_date': assignment.return_date.isoformat() if assignment.return_date else None,
                'is_active': assignment.is_active,  # Add this since it's in the model
                'notes': assignment.notes,
                'hours_used': hours_used,  # Calculated field
                'days_used': days_used,    # Calculated field
                'created_at': assignment.created_at.isoformat() if assignment.created_at else None,
                'updated_at': assignment.updated_at.isoformat() if assignment.updated_at else None  # Add this since it's in the model
            }
            assignments_data.append(assignment_data)
        
        print(f"Found {len(assignments_data)} recently used machines")
        
        return jsonify({
            'assignments': assignments_data,
            'count': len(assignments_data)
        }), 200
    
    except Exception as e:
        print(f"Error fetching recently used machines: {str(e)}")
        return jsonify({
            'message': f'Error fetching recently used machines: {str(e)}',
            'assignments': [],
            'count': 0
        }), 500