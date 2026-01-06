from flask import Blueprint, request, jsonify
from ..database import select, insert, update, delete
from datetime import datetime

habits_bp = Blueprint('habits', __name__)

@habits_bp.route('/habits.get', methods=['GET'])
def get_habits():
    """Get all habits for a user"""
    try:
        user_id = request.args.get('userId')
        frequency = request.args.get('frequency')
        
        if not user_id:
            return jsonify({'error': 'userId required'}), 400
        
        filters = {'user_id': int(user_id)}
        if frequency:
            filters['frequency'] = frequency
        
        result = select('habits', filters=filters)
        
        return jsonify({
            'success': True,
            'habits': result or []
        }), 200
        
    except Exception as e:
        print(f"Error in get_habits: {e}")
        return jsonify({'error': str(e)}), 500

@habits_bp.route('/habits.add', methods=['POST'])
def add_habit():
    """Add a new habit"""
    try:
        data = request.get_json()
        
        habit_data = {
            'user_id': data.get('userId'),
            'title': data.get('title'),
            'description': data.get('description'),
            'frequency': data.get('frequency'),
            'status': 'active',
            'do_it_at': data.get('doItAt'),
            'points': data.get('points', 10),
            'remind_me': data.get('remindMe', False)
        }
        
        result = insert('habits', habit_data)
        
        return jsonify({
            'success': True,
            'habitId': result[0]['id'] if result else None
        }), 201
        
    except Exception as e:
        print(f"Error in add_habit: {e}")
        return jsonify({'error': str(e)}), 500

@habits_bp.route('/habits.update', methods=['PUT'])
def update_habit():
    """Update a habit"""
    try:
        data = request.get_json()
        habit_id = data.get('habitId')
        user_id = data.get('userId')
        
        if not habit_id or not user_id:
            return jsonify({'error': 'habitId and userId required'}), 400
        
        update_data = {
            'status': data.get('status'),
            'last_updated': datetime.now().isoformat(),
        }
        
        # Add optional fields if provided
        if 'remindMe' in data:
            update_data['remind_me'] = data['remindMe']
        if 'doItAt' in data:
            update_data['do_it_at'] = data['doItAt']
        
        result = update(
            'habits',
            update_data,
            filters={'id': habit_id, 'user_id': user_id}
        )
        
        return jsonify({'success': True}), 200
        
    except Exception as e:
        print(f"Error in update_habit: {e}")
        return jsonify({'error': str(e)}), 500

@habits_bp.route('/habits.updateStatus', methods=['PUT'])
def update_habit_status():
    """Update habit status (completed/skipped/active)"""
    try:
        data = request.get_json()
        user_id = data.get('userId')
        title = data.get('title')
        status = data.get('status')
        
        if not all([user_id, title, status]):
            return jsonify({'error': 'userId, title, and status required'}), 400
        
        update_data = {
            'status': status,
            'last_updated': datetime.now().isoformat()
        }
        
        result = update(
            'habits',
            update_data,
            filters={'user_id': user_id, 'title': title}
        )
        
        return jsonify({'success': True}), 200
        
    except Exception as e:
        print(f"Error in update_habit_status: {e}")
        return jsonify({'error': str(e)}), 500

@habits_bp.route('/habits.delete', methods=['DELETE'])
def delete_habit():
    """Delete a habit"""
    try:
        habit_id = request.args.get('id')
        user_id = request.args.get('userId')
        
        if not habit_id or not user_id:
            return jsonify({'error': 'id and userId required'}), 400
        
        result = delete(
            'habits',
            filters={'id': int(habit_id), 'user_id': int(user_id)}
        )
        
        return jsonify({'success': True}), 200
        
    except Exception as e:
        print(f"Error in delete_habit: {e}")
        return jsonify({'error': str(e)}), 500

@habits_bp.route('/habits.getByTitle', methods=['GET'])
def get_habit_by_title():
    """Get a specific habit by title"""
    try:
        user_id = request.args.get('userId')
        title = request.args.get('title')
        
        if not user_id or not title:
            return jsonify({'error': 'userId and title required'}), 400
        
        result = select(
            'habits',
            filters={'user_id': int(user_id), 'title': title},
            single=True
        )
        
        return jsonify({
            'success': True,
            'habit': result
        }), 200
        
    except Exception as e:
        print(f"Error in get_habit_by_title: {e}")
        return jsonify({'error': str(e)}), 500

@habits_bp.route('/habits.checkExists', methods=['GET'])
def check_habit_exists():
    """Check if habit exists"""
    try:
        user_id = request.args.get('userId')
        title = request.args.get('title')
        frequency = request.args.get('frequency')
        
        if not user_id or not title:
            return jsonify({'error': 'userId and title required'}), 400
        
        filters = {'user_id': int(user_id), 'title': title}
        if frequency:
            filters['frequency'] = frequency
        
        result = select('habits', filters=filters, single=True)
        
        return jsonify({
            'success': True,
            'exists': result is not None
        }), 200
        
    except Exception as e:
        print(f"Error in check_habit_exists: {e}")
        return jsonify({'error': str(e)}), 500

@habits_bp.route('/habits.getCompleted', methods=['GET'])
def get_completed_habits():
    """Get count of completed habits"""
    try:
        user_id = request.args.get('userId')
        
        if not user_id:
            return jsonify({'error': 'userId required'}), 400
        
        result = select(
            'habits',
            filters={'user_id': int(user_id), 'status': 'completed'}
        )
        
        return jsonify({
            'success': True,
            'count': len(result) if result else 0
        }), 200
        
    except Exception as e:
        print(f"Error in get_completed_habits: {e}")
        return jsonify({'error': str(e)}), 500