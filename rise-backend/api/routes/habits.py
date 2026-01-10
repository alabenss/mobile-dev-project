from flask import Blueprint, request, jsonify
from ..database import select, insert, update, delete
from datetime import datetime, timedelta, timezone

habits_bp = Blueprint('habits', __name__)

def _parse_timestamp(timestamp_str):
    """Parse UTC timestamp from API and return as UTC datetime"""
    if not timestamp_str:
        return None
    
    # Handle ISO8601 timestamps with Z suffix
    if timestamp_str.endswith('Z'):
        return datetime.fromisoformat(timestamp_str.replace('Z', '+00:00'))
    
    # Try parsing as ISO8601
    try:
        dt = datetime.fromisoformat(timestamp_str)
        # If no timezone info, assume UTC
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        return dt
    except:
        return None

def _get_utc_now():
    """Get current time in UTC"""
    return datetime.now(timezone.utc)

def _is_same_day_utc(date1, date2):
    """Check if two UTC dates are the same calendar day in UTC"""
    if date1 is None or date2 is None:
        return False
    return (date1.year == date2.year and 
            date1.month == date2.month and 
            date1.day == date2.day)

def _is_same_week_utc(date1, date2):
    """Check if two UTC dates are in the same week"""
    if date1 is None or date2 is None:
        return False
    # Get Monday of each week
    monday1 = date1 - timedelta(days=date1.weekday())
    monday2 = date2 - timedelta(days=date2.weekday())
    return _is_same_day_utc(monday1, monday2)

def _is_same_month_utc(date1, date2):
    """Check if two UTC dates are in the same month"""
    if date1 is None or date2 is None:
        return False
    return date1.year == date2.year and date1.month == date2.month

def _handle_period_transition(habit, frequency, now):
    """Handle streak tracking when transitioning between periods"""
    last_updated_str = habit.get('last_updated')
    last_updated = _parse_timestamp(last_updated_str) if last_updated_str else None
    
    status = habit.get('status', 'active')
    habit_type = habit.get('habit_type', 'good')
    current_streak = habit.get('streak_count', 0)
    best_streak = habit.get('best_streak', 0)
    last_completed_date_str = habit.get('last_completed_date')
    last_completed_date = _parse_timestamp(last_completed_date_str) if last_completed_date_str else None
    
    streak_broken = False
    
    if frequency.lower() == 'daily':
        # Check if yesterday was completed
        yesterday = now - timedelta(days=1)
        
        if last_completed_date:
            # For good habits: streak breaks if yesterday wasn't completed
            if habit_type == 'good':
                if not _is_same_day_utc(last_completed_date, yesterday):
                    streak_broken = True
            # For bad habits: streak breaks if they did it yesterday
            else:
                # If status is 'completed' it means they did the bad habit
                if status == 'completed' and _is_same_day_utc(last_completed_date, yesterday):
                    streak_broken = True
        else:
            # No completion history - consider streak broken for good habits
            if habit_type == 'good':
                streak_broken = True
                    
    elif frequency.lower() == 'weekly':
        # Check if last week was completed
        last_week_start = now - timedelta(days=now.weekday() + 7)
        
        if last_completed_date:
            # Check if completion was in the previous week
            if habit_type == 'good':
                if not _is_same_week_utc(last_completed_date, last_week_start):
                    streak_broken = True
            else:
                if status == 'completed' and _is_same_week_utc(last_completed_date, last_week_start):
                    streak_broken = True
        else:
            if habit_type == 'good':
                streak_broken = True
                    
    elif frequency.lower() == 'monthly':
        # Check if last month was completed
        if now.month == 1:
            last_month = datetime(now.year - 1, 12, 1, tzinfo=timezone.utc)
        else:
            last_month = datetime(now.year, now.month - 1, 1, tzinfo=timezone.utc)
        
        if last_completed_date:
            if habit_type == 'good':
                if not _is_same_month_utc(last_completed_date, last_month):
                    streak_broken = True
            else:
                if status == 'completed' and _is_same_month_utc(last_completed_date, last_month):
                    streak_broken = True
        else:
            if habit_type == 'good':
                streak_broken = True
    
    if streak_broken:
        current_streak = 0
    
    return {
        'status': 'active',
        'last_updated': now.isoformat(),
        'streak_count': current_streak,
        'best_streak': best_streak
    }

@habits_bp.route('/habits.get', methods=['GET'])
def get_habits():
    """Get all habits for a user with automatic period resets"""
    try:
        user_id = request.args.get('userId')
        frequency = request.args.get('frequency')

        if not user_id:
            return jsonify({'error': 'userId required'}), 400
        
        filters = {'user_id': int(user_id)}
        if frequency:
            filters['frequency'] = frequency
        
        result = select('habits', filters=filters)

        if not result:
            return jsonify({'success': True, 'habits': []}), 200
        
        # Check if habits need reset based on period
        now = _get_utc_now()
        updated_habits = []
        
        for habit in result:
            last_updated_str = habit.get('last_updated')
            last_updated = _parse_timestamp(last_updated_str) if last_updated_str else None
            
            habit_frequency = habit['frequency']
            should_reset = False
            
            if last_updated:
                if habit_frequency.lower() == 'daily':
                    should_reset = not _is_same_day_utc(last_updated, now)
                elif habit_frequency.lower() == 'weekly':
                    should_reset = not _is_same_week_utc(last_updated, now)
                elif habit_frequency.lower() == 'monthly':
                    should_reset = not _is_same_month_utc(last_updated, now)
            
            if should_reset and habit['status'] != 'active':
                # Handle period transition and reset
                reset_data = _handle_period_transition(habit, habit_frequency, now)
                update('habits', reset_data, filters={'id': habit['id']})
                habit.update(reset_data)
            
            updated_habits.append(habit)
        
        return jsonify({
            'success': True,
            'habits': updated_habits
        }), 200
        
    except Exception as e:
        print(f"Error in get_habits: {e}")
        return jsonify({'error': str(e)}), 500

@habits_bp.route('/habits.add', methods=['POST'])
def add_habit():
    """Add a new habit"""
    try:
        data = request.get_json()
        now = _get_utc_now()
        
        habit_data = {
            'user_id': data.get('userId'),
            'title': data.get('title'),
            'description': data.get('description'),
            'frequency': data.get('frequency'),
            'status': 'active',
            'do_it_at': data.get('doItAt'),
            'points': data.get('points', 10),
            'remind_me': data.get('remindMe', False),
            'habit_type': data.get('habitType', 'good'),
            'streak_count': 0,
            'best_streak': 0,
            'is_task': data.get('isTask', True),
            'last_completed_date': None,
            'created_at': now.isoformat(),
            'last_updated': now.isoformat()
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
        habit_key = data.get('habitKey')
        user_id = data.get('userId')
        
        if not habit_key or not user_id:
            return jsonify({'error': 'habitKey and userId required'}), 400
        
        now = _get_utc_now()
        update_data = {
            'last_updated': now.isoformat(),
        }
        
        # Add optional fields if provided
        if 'remindMe' in data:
            update_data['remind_me'] = data['remindMe']
        if 'doItAt' in data:
            update_data['do_it_at'] = data['doItAt']
        if 'status' in data:
            update_data['status'] = data['status']
        
        result = update(
            'habits',
            update_data,
            filters={'title': habit_key, 'user_id': user_id}
        )
        
        return jsonify({'success': True}), 200
        
    except Exception as e:
        print(f"Error in update_habit: {e}")
        return jsonify({'error': str(e)}), 500

@habits_bp.route('/habits.updateStatus', methods=['PUT'])
def update_habit_status():
    """Update habit status with streak tracking and task-to-habit conversion"""
    try:
        data = request.get_json()
        user_id = data.get('userId')
        title = data.get('title')
        status = data.get('status')
        
        if not all([user_id, title, status]):
            return jsonify({'error': 'userId, title, and status required'}), 400
        
        # Get current habit data
        habit = select('habits', filters={'user_id': user_id, 'title': title}, single=True)
        if not habit:
            return jsonify({'error': 'Habit not found'}), 404
        
        now = _get_utc_now()
        current_streak = habit.get('streak_count', 0)
        best_streak = habit.get('best_streak', 0)
        habit_type = habit.get('habit_type', 'good')
        is_task = habit.get('is_task', True)
        last_completed_str = habit.get('last_completed_date')
        last_completed = _parse_timestamp(last_completed_str) if last_completed_str else None
        
        # Calculate new streak based on status
        new_streak = current_streak
        new_best_streak = best_streak
        new_last_completed = last_completed
        new_is_task = is_task
        
        if status == 'completed':
            # For good habits, increment streak
            if habit_type == 'good':
                new_streak = current_streak + 1
                if new_streak > best_streak:
                    new_best_streak = new_streak
                new_last_completed = now
                
                # Check if task should become habit (10 consecutive completions)
                if is_task and new_streak >= 10:
                    new_is_task = False
            # For bad habits, 'completed' means they did the bad habit - break streak
            else:
                new_streak = 0
                new_last_completed = now
        
        elif status == 'skipped':
            # For bad habits, 'skipped' means they resisted - increment streak
            if habit_type == 'bad':
                new_streak = current_streak + 1
                if new_streak > best_streak:
                    new_best_streak = new_streak
                new_last_completed = now
                
                # Check if task should become habit (10 consecutive resistances)
                if is_task and new_streak >= 10:
                    new_is_task = False
            # For good habits, skipping breaks the streak
            else:
                new_streak = 0
                new_last_completed = now
        
        elif status == 'active':
            # Resetting - keep current streak and last_completed_date
            pass
        
        update_data = {
            'status': status,
            'last_updated': now.isoformat(),
            'streak_count': new_streak,
            'best_streak': new_best_streak,
            'is_task': new_is_task,
            'last_completed_date': new_last_completed.isoformat() if new_last_completed else None
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

@habits_bp.route('/habits.restoreStreak', methods=['POST'])
def restore_streak():
    """Restore a broken streak using points - only available within grace period"""
    try:
        data = request.get_json()
        user_id = data.get('userId')
        habit_key = data.get('habitKey')
        
        if not all([user_id, habit_key]):
            return jsonify({'error': 'userId and habitKey required'}), 400
        
        # Get habit
        habit = select('habits', filters={'user_id': user_id, 'title': habit_key}, single=True)
        if not habit:
            return jsonify({'error': 'Habit not found'}), 404
        
        # Check if within grace period
        last_completed_date_str = habit.get('last_completed_date')
        if not last_completed_date_str:
            return jsonify({'error': 'No completion history'}), 400
        
        now = _get_utc_now()
        last_completed = _parse_timestamp(last_completed_date_str)
        if not last_completed:
            return jsonify({'error': 'Invalid completion date'}), 400
            
        frequency = habit['frequency'].lower()
        
        # Check grace period (allow 2-3 days window instead of exactly 2)
        within_grace_period = False
        
        if frequency == 'daily':
            days_since = (now.date() - last_completed.date()).days
            within_grace_period = days_since in [2, 3]  # Extended grace period
        elif frequency == 'weekly':
            def get_week_start(date):
                return date - timedelta(days=date.weekday())
            weeks_since = (get_week_start(now) - get_week_start(last_completed)).days // 7
            within_grace_period = weeks_since in [2, 3]
        elif frequency == 'monthly':
            months_since = (now.year - last_completed.year) * 12 + now.month - last_completed.month
            within_grace_period = months_since in [2, 3]
        
        if not within_grace_period:
            return jsonify({'error': 'Grace period expired'}), 400
        
        # Get user's current points
        user = select('users', filters={'id': user_id}, single=True)
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        current_points = user.get('total_points', 0)
        best_streak = habit.get('best_streak', 0)
        restoration_cost = best_streak * 10  # 10 points per streak day
        
        if current_points < restoration_cost:
            return jsonify({'error': 'Insufficient points'}), 400
        
        # Deduct points and restore streak
        update('users', 
               {'total_points': current_points - restoration_cost},
               filters={'id': user_id})
        
        update('habits',
               {
                   'streak_count': best_streak,
                   'last_completed_date': now.isoformat(),
                   'status': 'completed',
                   'last_updated': now.isoformat()
               },
               filters={'user_id': user_id, 'title': habit_key})
        
        return jsonify({'success': True}), 200
        
    except Exception as e:
        print(f"Error in restore_streak: {e}")
        return jsonify({'error': str(e)}), 500

@habits_bp.route('/habits.checkReset', methods=['POST'])
def check_and_reset():
    """Check and reset old habits"""
    try:
        data = request.get_json()
        user_id = data.get('userId')
        
        if not user_id:
            return jsonify({'error': 'userId required'}), 400
        
        habits = select('habits', filters={'user_id': user_id})
        now = _get_utc_now()
        
        for habit in habits:
            last_updated_str = habit.get('last_updated')
            last_updated = _parse_timestamp(last_updated_str) if last_updated_str else None
            
            if not last_updated:
                continue
                
            frequency = habit['frequency']
            should_reset = False
            
            if frequency.lower() == 'daily':
                should_reset = not _is_same_day_utc(last_updated, now)
            elif frequency.lower() == 'weekly':
                should_reset = not _is_same_week_utc(last_updated, now)
            elif frequency.lower() == 'monthly':
                should_reset = not _is_same_month_utc(last_updated, now)
            
            if should_reset and habit['status'] != 'active':
                reset_data = _handle_period_transition(habit, frequency, now)
                update('habits', reset_data, filters={'id': habit['id']})
        
        return jsonify({'success': True}), 200
        
    except Exception as e:
        print(f"Error in check_and_reset: {e}")
        return jsonify({'error': str(e)}), 500

@habits_bp.route('/habits.resetDaily', methods=['POST'])
def reset_daily():
    """Reset all daily habits"""
    try:
        data = request.get_json()
        user_id = data.get('userId')
        
        if not user_id:
            return jsonify({'error': 'userId required'}), 400
        
        now = _get_utc_now()
        update('habits',
               {'status': 'active', 'last_updated': now.isoformat()},
               filters={'user_id': user_id, 'frequency': 'Daily'})
        
        return jsonify({'success': True}), 200
        
    except Exception as e:
        print(f"Error in reset_daily: {e}")
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
    """Check if habit exists with given title and frequency"""
    try:
        user_id = request.args.get('userId')
        title = request.args.get('title')
        frequency = request.args.get('frequency')

        if not user_id or not title:
            return jsonify({'error': 'userId and title are required'}), 400

        # Check if habit exists with user, title, and optionally frequency
        filters = {
            'user_id': int(user_id),
            'title': title,
        }
        
        if frequency:
            filters['frequency'] = frequency

        habits = select('habits', filters=filters)

        return jsonify({
            'success': True,
            'exists': len(habits) > 0
        }), 200

    except Exception as e:
        print(f"Error in check_habit_exists: {e}")
        return jsonify({'error': 'Internal server error'}), 500

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