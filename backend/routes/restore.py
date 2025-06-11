from flask import Blueprint, request, jsonify
from werkzeug.exceptions import BadRequest
from models import db_session
from flask_jwt_extended import jwt_required  # Import jwt_required from flask_jwt_extended
from utils.security import admin_required    # Import admin_required from utils.security
import logging

restore_api = Blueprint('restore_api', __name__)

@restore_api.route('/restore', methods=['POST'])
@jwt_required()
@admin_required
def restore_full_backup():
    try:
        data = request.get_json()
        
        if not data or 'data' not in data:
            return jsonify({'success': False, 'message': 'Invalid backup format'}), 400
        
        backup_data = data['data']
        restored_counts = {
            'machinery': 0,
            'rice_varieties': 0,
            'users': 0
        }
        
        # Import models here to avoid circular imports
        from models.machinery import Machinery
        from models.rice import RiceVariety
        from models.user import User
        
        # Clear existing data first (except admin user)
        try:
            # Delete in reverse order of dependencies
            db_session.query(RiceVariety).delete()
            db_session.query(Machinery).delete()
            db_session.query(User).filter(User.username != 'admin').delete()
            db_session.commit()
            logging.info("Cleared existing data before restore")
        except Exception as clear_error:
            db_session.rollback()
            logging.warning(f"Could not clear existing data: {clear_error}")
        
        # Restore machinery first (usually no dependencies)
        if 'machinery' in backup_data:
            for machinery_data in backup_data['machinery']:
                try:
                    machinery = Machinery(
                        machine_name=machinery_data.get('machine_name'),
                        is_mobile=machinery_data.get('is_mobile', True),
                        is_active=machinery_data.get('is_active', True)
                    )
                    db_session.add(machinery)
                    db_session.flush()  # Flush to get ID without committing
                    restored_counts['machinery'] += 1
                except Exception as e:
                    logging.warning(f"Failed to restore machinery {machinery_data.get('machine_name')}: {e}")
                    continue
        
        # Restore rice varieties
        if 'rice_varieties' in backup_data:
            for rice_data in backup_data['rice_varieties']:
                try:
                    rice_variety = RiceVariety(
                        variety_name=rice_data.get('variety_name'),
                        quality_grade=rice_data.get('quality_grade'),
                        production_date=rice_data.get('production_date'),
                        expiration_date=rice_data.get('expiration_date')
                    )
                    db_session.add(rice_variety)
                    db_session.flush()
                    restored_counts['rice_varieties'] += 1
                except Exception as e:
                    logging.warning(f"Failed to restore rice variety {rice_data.get('variety_name')}: {e}")
                    continue
        
        # Restore users (excluding admin)
        if 'users' in backup_data:
            for user_data in backup_data['users']:
                try:
                    username = user_data.get('username')
                    if username and username != 'admin':
                        user = User(
                            username=username,
                            password='default123',  # Set a default password
                            security_question=user_data.get('security_question', 'What is your favorite color?'),
                            security_answer=user_data.get('security_answer', 'blue'),
                            is_admin=user_data.get('is_admin', False)
                        )
                        db_session.add(user)
                        db_session.flush()
                        restored_counts['users'] += 1
                except Exception as e:
                    logging.warning(f"Failed to restore user {user_data.get('username')}: {e}")
                    continue
        
        # Commit all changes
        db_session.commit()
        
        return jsonify({
            'success': True,
            'message': 'Data restored successfully',
            'restored_counts': restored_counts
        }), 200
        
    except Exception as e:
        db_session.rollback()
        logging.error(f"Restore error: {str(e)}")
        return jsonify({'success': False, 'message': f'Restore failed: {str(e)}'}), 500

@restore_api.route('/restore/machinery', methods=['POST'])
@jwt_required()
@admin_required
def restore_machinery():
    try:
        data = request.get_json()
        
        if not data or 'machinery' not in data:
            return jsonify({'success': False, 'message': 'Invalid machinery data format'}), 400
        
        from models.machinery import Machinery
        
        restored_count = 0
        for machinery_data in data['machinery']:
            existing = Machinery.query.filter_by(machine_name=machinery_data.get('machine_name')).first()
            if not existing:
                machinery = Machinery(
                    machine_name=machinery_data.get('machine_name'),
                    is_mobile=machinery_data.get('is_mobile', True),
                    is_active=machinery_data.get('is_active', True)
                )
                db_session.add(machinery)
                restored_count += 1
        
        db_session.commit()
        
        return jsonify({
            'success': True,
            'message': f'Restored {restored_count} machinery records',
            'restored_count': restored_count
        }), 200
        
    except Exception as e:
        db_session.rollback()
        logging.error(f"Machinery restore error: {str(e)}")
        return jsonify({'success': False, 'message': f'Restore failed: {str(e)}'}), 500

@restore_api.route('/restore/rice-varieties', methods=['POST'])
@jwt_required()
@admin_required
def restore_rice_varieties():
    try:
        data = request.get_json()
        
        if not data or 'rice_varieties' not in data:
            return jsonify({'success': False, 'message': 'Invalid rice varieties data format'}), 400
        
        from models.rice import RiceVariety
        
        restored_count = 0
        for rice_data in data['rice_varieties']:
            existing = RiceVariety.query.filter_by(variety_name=rice_data.get('variety_name')).first()
            if not existing:
                rice_variety = RiceVariety(
                    variety_name=rice_data.get('variety_name'),
                    quality_grade=rice_data.get('quality_grade'),
                    production_date=rice_data.get('production_date'),
                    expiration_date=rice_data.get('expiration_date')
                )
                db_session.add(rice_variety)
                restored_count += 1
        
        db_session.commit()
        
        return jsonify({
            'success': True,
            'message': f'Restored {restored_count} rice variety records',
            'restored_count': restored_count
        }), 200
        
    except Exception as e:
        db_session.rollback()
        logging.error(f"Rice varieties restore error: {str(e)}")
        return jsonify({'success': False, 'message': f'Restore failed: {str(e)}'}), 500