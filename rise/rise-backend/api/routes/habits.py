from flask import Blueprint, request, jsonify
from ..database import select, insert, update, delete
from datetime import datetime, timedelta

habits_bp = Blueprint('habits', __name__)

def _is_same_day(date1, date2):
    """Check if two dates are the same day"""
    return (date1.year == date2.year and 
            date1.month == date2.month and 
            date1.day == date2.day)

def _is_same_week(date1, date2):
    """Check if two dates are in the same week"""
    # Get Monday of each week
    monday1 = date1 - timedelta(days=date1.weekday())
    monday2 = date2 - timedelta(days=date2.weekday())
    return _is_same_day(monday1, monday2)

def _is_same_month(date1, date2):
    """Check if two dates are in the same month"""
    return date1.year == date2.year and date1.month == date2.month

def _handle_period_transition(habit, frequency, now):
    """Handle streak tracking when transitioning between periods"""
    last_updated = datetime.fromisoformat(habit['last_updated'])
    status = habit.get('status', 'active')
    habit_type = habit.get('habit_type', 'good')
    current_streak = habit.get('streak_count', 0)
    best_streak = habit.get('best_streak', 0)
    last_completed_date = habit.get('last_completed_date')
    
    streak_broken = False
    
    if frequency.lower() == 'daily':
        yesterday = now - timedelta(days=1)
        if last_completed_date:
            last_completed = datetime.fromisoformat(last_completed_date)
            if not _is_same_day(last_completed, yesterday):
                if habit_type == 'good':
                    streak_broken = True
            elif status == 'completed' or (habit_type == 'bad' and status == 'skipped'):
                current_streak += 1
                if current_streak > best_streak:
                    best_streak = current_streak
        elif habit_type == 'good' and current_streak > 0:
            streak_broken = True
            
    elif frequency.lower() == 'weekly':
        last_week = now - timedelta(days=7)
        if last_completed_date:
            last_completed = datetime.fromisoformat(last_completed_date)
            if not _is_same_week(last_completed, last_week):
                if habit_type == 'good':
                    streak_broken = True
            elif status == 'completed' or (habit_type == 'bad' and status == 'skipped'):
                current_streak += 1
                if current_streak > best_streak:
                    best_streak = current_streak
        elif habit_type == 'good' and current_streak > 0:
            streak_broken = True
            
    elif frequency.lower() == 'monthly':
        if last_completed_date:
            last_completed = datetime.fromisoformat(last_completed_date)
            last_month = datetime(now.year, now.month - 1 if now.month > 1 else 12, now.day)
            if not _is_same_month(last_completed, last_month):
                if habit_type == 'good':
                    streak_broken = True
            elif status == 'completed' or (habit_type == 'bad' and status == 'skipped'):
                current_streak += 1
                if current_streak > best_streak:
                    best_streak = current_streak
        elif habit_type == 'good' and current_streak > 0:
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
        start_date = request.args.get('startDate')
        end_date = request.args.get('endDate')

        
        if not user_id:
            return jsonify({'error': 'userId required'}), 400
        
        filters = {'user_id': int(user_id)}
        if frequency:
            filters['frequency'] = frequency
        
        result = select('habits', filters=filters)

        if start_date and end_date:
            start = datetime.fromisoformat(start_date)
            end = datetime.fromisoformat(end_date)
            result = [
                h for h in result
                if h['last_created'] and start <= datetime.fromisoformat(h['last_created']) <= end
            ]
        
        if not result:
            return jsonify({'success': True, 'habits': []}), 200
        
        # Check if habits need reset based on period
        now = datetime.now()
        updated_habits = []
        
        for habit in result:
            last_updated = datetime.fromisoformat(habit['last_updated'])
            habit_frequency = habit['frequency']
            should_reset = False
            
            if habit_frequency.lower() == 'daily':
                should_reset = not _is_same_day(last_updated, now)
            elif habit_frequency.lower() == 'weekly':
                should_reset = not _is_same_week(last_updated, now)
            elif habit_frequency.lower() == 'monthly':
                should_reset = not _is_same_month(last_updated, now)
            
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
            'task_completion_count': 0,
            'last_completed_date': None,
            'last_updated': datetime.now().isoformat()
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
        
        update_data = {
            'last_updated': datetime.now().isoformat(),
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
        
        new_streak = data.get('streakCount', habit.get('streak_count', 0))
        new_best_streak = data.get('bestStreak', habit.get('best_streak', 0))
        new_task_completion = data.get('taskCompletionCount', habit.get('task_completion_count', 0))
        new_is_task = data.get('isTask', habit.get('is_task', True))
        last_completed_date = data.get('lastCompletedDate', habit.get('last_completed_date'))
        
        update_data = {
            'status': status,
            'last_updated': datetime.now().isoformat(),
            'streak_count': new_streak,
            'best_streak': new_best_streak,
            'task_completion_count': new_task_completion,
            'is_task': new_is_task,
            'last_completed_date': last_completed_date
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
    """Restore a broken streak using points"""
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
                   'last_completed_date': datetime.now().isoformat()
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
        now = datetime.now()
        
        for habit in habits:
            last_updated = datetime.fromisoformat(habit['last_updated'])
            frequency = habit['frequency']
            should_reset = False
            
            if frequency.lower() == 'daily':
                should_reset = not _is_same_day(last_updated, now)
            elif frequency.lower() == 'weekly':
                should_reset = not _is_same_week(last_updated, now)
            elif frequency.lower() == 'monthly':
                should_reset = not _is_same_month(last_updated, now)
            
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
        
        update('habits',
               {'status': 'active', 'last_updated': datetime.now().isoformat()},
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