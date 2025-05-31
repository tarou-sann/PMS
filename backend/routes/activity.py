from flask import request, jsonify
from routes import api
from models import db_session
from datetime import datetime

# Simple in-memory storage for now (you can add a proper model later)
activity_logs = []

@api.route('/activity-logs', methods=['POST'])
def log_activity():
    """Log user activity"""
    try:
        data = request.get_json()
        
        # Create activity log entry
        activity_entry = {
            'id': len(activity_logs) + 1,
            'username': data.get('username', 'Unknown'),
            'action': data.get('action', 'Unknown'),
            'details': data.get('details', ''),
            'target': data.get('target', ''),
            'timestamp': data.get('timestamp', datetime.now().isoformat())
        }
        
        activity_logs.append(activity_entry)
        
        return jsonify({'message': 'Activity logged successfully'}), 201
        
    except Exception as e:
        return jsonify({'message': f'Error logging activity: {str(e)}'}), 500

@api.route('/activity-logs', methods=['GET'])
def get_activities():
    """Get all activities"""
    try:
        # Return activities in reverse order (newest first)
        return jsonify({
            'activities': list(reversed(activity_logs))
        }), 200
        
    except Exception as e:
        return jsonify({'message': f'Error getting activities: {str(e)}'}), 500

@api.route('/activity-logs', methods=['OPTIONS'])
def handle_options():
    """Handle CORS preflight request"""
    return '', 200