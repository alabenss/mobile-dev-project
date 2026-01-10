from flask import Blueprint, request, jsonify
from ..database import select, insert, update
from datetime import datetime

home_bp = Blueprint('home', __name__)

@home_bp.route('/home.status', methods=['GET'])
def get_status():
    """Get home status for a specific date"""
    try:
        user_id = request.args.get('userId')
        date = request.args.get('date')  # Expected format: yyyy-MM-dd
        
        if not user_id or not date:
            return jsonify({'error': 'userId and date required'}), 400
        
        result = select(
            'home_status',
            filters={'user_id': int(user_id), 'date': date},
            single=True
        )
        
        # Return default values if not found
        if not result:
            result = {
                'water_count': 0,
                'water_goal': 8,
                'detox_progress': 0.0
            }
        
        return jsonify({
            'success': True,
            'status': result
        }), 200
        
    except Exception as e:
        print(f"Error in get_status: {e}")
        return jsonify({'error': str(e)}), 500

@home_bp.route('/home.status', methods=['POST'])
def save_status():
    """Save or update home status for a specific date"""
    try:
        data = request.get_json()
        user_id = data.get('userId')
        date = data.get('date')
        status = data.get('status')
        
        if not all([user_id, date, status]):
            return jsonify({'error': 'Missing required fields'}), 400
        
        # Check if status exists for this date
        existing = select(
            'home_status',
            filters={'user_id': user_id, 'date': date},
            single=True
        )
        
        status_data = {
            'water_count': status.get('waterCount', 0),
            'water_goal': status.get('waterGoal', 8),
            'detox_progress': status.get('detoxProgress', 0.0)
        }
        
        if existing:
            # Update existing status
            result = update(
                'home_status',
                status_data,
                filters={'user_id': user_id, 'date': date}
            )
        else:
            # Insert new status
            status_data['user_id'] = user_id
            status_data['date'] = date
            result = insert('home_status', status_data)
        
        return jsonify({'success': True}), 200
        
    except Exception as e:
        print(f"Error in save_status: {e}")
        return jsonify({'error': str(e)}), 500

@home_bp.route('/home.incrementWater', methods=['POST'])
def increment_water():
    """Increment water count for today"""
    try:
        data = request.get_json()
        user_id = data.get('userId')
        date = data.get('date')
        
        if not all([user_id, date]):
            return jsonify({'error': 'userId and date required'}), 400
        
        # Get current status
        existing = select(
            'home_status',
            filters={'user_id': user_id, 'date': date},
            single=True
        )
        
        if existing:
            # Increment water count
            new_count = existing.get('water_count', 0) + 1
            result = update(
                'home_status',
                {'water_count': new_count},
                filters={'user_id': user_id, 'date': date}
            )
        else:
            # Create new status with count = 1
            result = insert('home_status', {
                'user_id': user_id,
                'date': date,
                'water_count': 1,
                'water_goal': 8,
                'detox_progress': 0.0
            })
        
        return jsonify({'success': True}), 200
        
    except Exception as e:
        print(f"Error in increment_water: {e}")
        return jsonify({'error': str(e)}), 500

@home_bp.route('/home.decrementWater', methods=['POST'])
def decrement_water():
    """Decrement water count for today"""
    try:
        data = request.get_json()
        user_id = data.get('userId')
        date = data.get('date')
        
        if not all([user_id, date]):
            return jsonify({'error': 'userId and date required'}), 400
        
        # Get current status
        existing = select(
            'home_status',
            filters={'user_id': user_id, 'date': date},
            single=True
        )
        
        if existing:
            # Decrement water count (don't go below 0)
            current_count = existing.get('water_count', 0)
            new_count = max(0, current_count - 1)
            result = update(
                'home_status',
                {'water_count': new_count},
                filters={'user_id': user_id, 'date': date}
            )
        
        return jsonify({'success': True}), 200
        
    except Exception as e:
        print(f"Error in decrement_water: {e}")
        return jsonify({'error': str(e)}), 500

@home_bp.route('/home.updateDetox', methods=['POST'])
def update_detox():
    """Update detox progress"""
    try:
        data = request.get_json()
        user_id = data.get('userId')
        date = data.get('date')
        detox_progress = data.get('detoxProgress')
        
        if not all([user_id, date]) or detox_progress is None:
            return jsonify({'error': 'Missing required fields'}), 400
        
        # Get current status
        existing = select(
            'home_status',
            filters={'user_id': user_id, 'date': date},
            single=True
        )
        
        if existing:
            # Update detox progress
            result = update(
                'home_status',
                {'detox_progress': detox_progress},
                filters={'user_id': user_id, 'date': date}
            )
        else:
            # Create new status
            result = insert('home_status', {
                'user_id': user_id,
                'date': date,
                'water_count': 0,
                'water_goal': 8,
                'detox_progress': detox_progress
            })
        
        return jsonify({'success': True}), 200
        
    except Exception as e:
        print(f"Error in update_detox: {e}")
        return jsonify({'error': str(e)}), 500

@home_bp.route('/home.getRange', methods=['GET'])
def get_range():
    """Get home status for a date range"""
    try:
        user_id = request.args.get('userId')
        start_date = request.args.get('startDate')
        end_date = request.args.get('endDate')
        
        if not all([user_id, start_date, end_date]):
            return jsonify({'error': 'userId, startDate, and endDate required'}), 400
        
        # Get all statuses for user (Supabase doesn't support range queries easily)
        result = select(
            'home_status',
            filters={'user_id': int(user_id)}
        )
        
        # Filter by date range
        if result:
            filtered = []
            for status in result:
                status_date = status.get('date', '')
                if start_date <= status_date <= end_date:
                    filtered.append(status)
            result = filtered
        
        return jsonify({
            'success': True,
            'statuses': result or []
        }), 200
        
    except Exception as e:
        print(f"Error in get_range: {e}")
        return jsonify({'error': str(e)}), 500