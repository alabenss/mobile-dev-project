from flask import Blueprint, request, jsonify
from ..database import select, insert, update, delete
from datetime import datetime

from datetime import datetime

def normalize_date(date_str: str) -> str:
    return datetime.fromisoformat(date_str[:10]).date().isoformat()

moods_bp = Blueprint('moods', __name__)

@moods_bp.route('/moods.today', methods=['GET'])
def get_today_mood():
    """Get mood for a specific date"""
    try:
        user_id = request.args.get('userId')
        date = request.args.get('date')  # Expected format: yyyy-MM-dd
        
        if not user_id or not date:
            return jsonify({'error': 'userId and date required'}), 400
        
        result = select(
            'daily_moods',
            filters={'user_id': int(user_id), 'date': date},
            single=True
        )
        
        return jsonify({
            'success': True,
            'mood': result
        }), 200
        
    except Exception as e:
        print(f"Error in get_today_mood: {e}")
        return jsonify({'error': str(e)}), 500

@moods_bp.route('/moods.save', methods=['POST'])
def save_mood():
    """Save or update mood for a specific date"""
    try:
        data = request.get_json()
        user_id = data.get('userId')
        date = normalize_date(data.get('date'))
        mood_image = data.get('moodImage')
        mood_label = data.get('moodLabel')
        
        if not all([user_id, date, mood_image, mood_label]):
            return jsonify({'error': 'Missing required fields'}), 400
        
        # Check if mood exists for this date
        existing = select(
            'daily_moods',
            filters={'user_id': user_id, 'date': date},
            single=True
        )
        
        now = datetime.now().isoformat()
        
        if existing:
            # Update existing mood
            result = update(
                'daily_moods',
                {
                    'mood_image': mood_image,
                    'mood_label': mood_label,
                    'updated_at': now
                },
                filters={'user_id': user_id, 'date': date}
            )
        else:
            # Insert new mood
            result = insert('daily_moods', {
                'user_id': user_id,
                'date': date,
                'mood_image': mood_image,
                'mood_label': mood_label,
                'created_at': now,
                'updated_at': now
            })
        
        return jsonify({'success': True}), 200
        
    except Exception as e:
        print(f"Error in save_mood: {e}")
        return jsonify({'error': str(e)}), 500

@moods_bp.route('/moods.delete', methods=['DELETE'])
def delete_mood():
    """Delete mood for a specific date"""
    try:
        user_id = request.args.get('userId')
        date = normalize_date(request.args.get('date'))
        
        if not user_id or not date:
            return jsonify({'error': 'userId and date required'}), 400
        
        result = delete(
            'daily_moods',
            filters={'user_id': int(user_id), 'date': date}
        )
        
        return jsonify({'success': True}), 200
        
    except Exception as e:
        print(f"Error in delete_mood: {e}")
        return jsonify({'error': str(e)}), 500

@moods_bp.route('/moods.getAll', methods=['GET'])
def get_all_moods():
    """Get all moods for a user"""
    try:
        user_id = request.args.get('userId')
        
        if not user_id:
            return jsonify({'error': 'userId required'}), 400
        
        result = select(
            'daily_moods',
            filters={'user_id': int(user_id)}
        )
        
        # Sort by date descending
        if result:
            result = sorted(result, key=lambda x: x.get('date', ''), reverse=True)
        
        return jsonify({
            'success': True,
            'moods': result or []
        }), 200
        
    except Exception as e:
        print(f"Error in get_all_moods: {e}")
        return jsonify({'error': str(e)}), 500

@moods_bp.route('/moods.getByMonth', methods=['GET'])
def get_moods_by_month():
    """Get moods for a specific month"""
    try:
        user_id = request.args.get('userId')
        month = request.args.get('month')
        year = request.args.get('year')
        
        if not all([user_id, month, year]):
            return jsonify({'error': 'userId, month, and year required'}), 400
        
        # Get all moods for user
        result = select(
            'daily_moods',
            filters={'user_id': int(user_id)}
        )
        
        # Filter by month and year
        if result:
            filtered = []
            for mood in result:
                mood_date = mood.get('date', '')
                if mood_date:
                    # Parse date (format: yyyy-MM-dd)
                    parts = mood_date.split('-')
                    if len(parts) == 3:
                        mood_year = parts[0]
                        mood_month = parts[1]
                        if mood_year == year and mood_month == month.zfill(2):
                            filtered.append(mood)
            result = filtered
        
        return jsonify({
            'success': True,
            'moods': result or []
        }), 200
        
    except Exception as e:
        print(f"Error in get_moods_by_month: {e}")
        return jsonify({'error': str(e)}), 500