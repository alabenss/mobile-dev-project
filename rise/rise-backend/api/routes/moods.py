from flask import Blueprint, request, jsonify
from ..database import select, insert, update, delete
from datetime import datetime, timezone

def normalize_date(date_str: str) -> str:
    """Normalize date string to YYYY-MM-DD format"""
    # Just take the first 10 characters (YYYY-MM-DD)
    # This handles both "2026-01-08" and "2026-01-08T17:37:32.918067Z"
    return date_str[:10]

def get_utc_timestamp() -> str:
    """Get current UTC timestamp with Z suffix"""
    return datetime.now(timezone.utc).isoformat().replace('+00:00', 'Z')

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
        
        # Add Z suffix to timestamps if they exist
        if result:
            if 'created_at' in result and result['created_at']:
                # If it's already a datetime object from Supabase
                if isinstance(result['created_at'], datetime):
                    result['created_at'] = result['created_at'].replace(tzinfo=timezone.utc).isoformat().replace('+00:00', 'Z')
                elif isinstance(result['created_at'], str) and not result['created_at'].endswith('Z'):
                    result['created_at'] = result['created_at'] + 'Z'
            
            if 'updated_at' in result and result['updated_at']:
                if isinstance(result['updated_at'], datetime):
                    result['updated_at'] = result['updated_at'].replace(tzinfo=timezone.utc).isoformat().replace('+00:00', 'Z')
                elif isinstance(result['updated_at'], str) and not result['updated_at'].endswith('Z'):
                    result['updated_at'] = result['updated_at'] + 'Z'
        
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
        
        now = get_utc_timestamp()
        
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
        
        # Fix timestamps for all moods
        if result:
            for mood in result:
                if 'created_at' in mood and mood['created_at']:
                    if isinstance(mood['created_at'], datetime):
                        mood['created_at'] = mood['created_at'].replace(tzinfo=timezone.utc).isoformat().replace('+00:00', 'Z')
                    elif isinstance(mood['created_at'], str) and not mood['created_at'].endswith('Z'):
                        mood['created_at'] = mood['created_at'] + 'Z'
                
                if 'updated_at' in mood and mood['updated_at']:
                    if isinstance(mood['updated_at'], datetime):
                        mood['updated_at'] = mood['updated_at'].replace(tzinfo=timezone.utc).isoformat().replace('+00:00', 'Z')
                    elif isinstance(mood['updated_at'], str) and not mood['updated_at'].endswith('Z'):
                        mood['updated_at'] = mood['updated_at'] + 'Z'
            
            # Sort by date descending
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
                # Fix timestamps
                if 'created_at' in mood and mood['created_at']:
                    if isinstance(mood['created_at'], datetime):
                        mood['created_at'] = mood['created_at'].replace(tzinfo=timezone.utc).isoformat().replace('+00:00', 'Z')
                    elif isinstance(mood['created_at'], str) and not mood['created_at'].endswith('Z'):
                        mood['created_at'] = mood['created_at'] + 'Z'
                
                if 'updated_at' in mood and mood['updated_at']:
                    if isinstance(mood['updated_at'], datetime):
                        mood['updated_at'] = mood['updated_at'].replace(tzinfo=timezone.utc).isoformat().replace('+00:00', 'Z')
                    elif isinstance(mood['updated_at'], str) and not mood['updated_at'].endswith('Z'):
                        mood['updated_at'] = mood['updated_at'] + 'Z'
                
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