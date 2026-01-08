from flask import Blueprint, request, jsonify
from ..database import select, insert, update

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/user.register', methods=['POST'])
def register():
    """Register a new user"""
    try:
        data = request.get_json()
        first_name = data.get('firstName')
        last_name = data.get('lastName')
        username = data.get('username')
        email = data.get('email')
        password = data.get('password')
        
        if not all([first_name, last_name, username, email, password]):
            return jsonify({'error': 'Missing required fields'}), 400
        
        # Check if email exists
        existing_email = select('users', filters={'email': email})
        if existing_email:
            return jsonify({'error': 'Email already exists'}), 400
        
        # Check if username exists
        existing_username = select('users', filters={'username': username})
        if existing_username:
            return jsonify({'error': 'Username already exists'}), 400
        
        # Create user
        result = insert('users', {
            'first_name': first_name,
            'last_name': last_name,
            'username': username,
            'email': email,
            'password': password,
            'total_points': 0,
            'stars': 0
        })
        
        if result:
            return jsonify({
                'success': True,
                'user': result[0]
            }), 201
        else:
            return jsonify({'error': 'Failed to create user'}), 500
        
    except Exception as e:
        print(f"Error in register: {e}")
        return jsonify({'error': str(e)}), 500

@auth_bp.route('/user.login', methods=['POST'])
def login():
    """Login user (email OR username)"""
    try:
        data = request.get_json()
        identifier = data.get('email')  # can be email or username
        password = data.get('password')

        if not all([identifier, password]):
            return jsonify({'error': 'Missing credentials'}), 400

        # First try login by email
        result = select(
            'users',
            columns='id, first_name, last_name, username, email, total_points, stars',
            filters={'email': identifier, 'password': password},
            single=True
        )

        # If not found, try login by username
        if not result:
            result = select(
                'users',
                columns='id, first_name, last_name, username, email, total_points, stars',
                filters={'username': identifier, 'password': password},
                single=True
            )

        if not result:
            return jsonify({'error': 'Invalid credentials'}), 401

        return jsonify({
            'success': True,
            'user': result
        }), 200

    except Exception as e:
        print(f"Error in login: {e}")
        return jsonify({'error': str(e)}), 500

@auth_bp.route('/user.profile', methods=['GET'])
def get_profile():
    """Get user profile"""
    try:
        user_id = request.args.get('userId')
        
        if not user_id:
            return jsonify({'error': 'userId required'}), 400
        
        result = select(
            'users',
            columns='id, first_name, last_name, username, email, total_points, stars, created_at',
            filters={'id': int(user_id)},
            single=True
        )
        
        if not result:
            return jsonify({'error': 'User not found'}), 404
        
        return jsonify({
            'success': True,
            'user': result
        }), 200
        
    except Exception as e:
        print(f"Error in get_profile: {e}")
        return jsonify({'error': str(e)}), 500

@auth_bp.route('/user.updateProfile', methods=['PUT'])
def update_profile():
    """Update user profile (first_name, last_name, username, email)"""
    try:
        data = request.get_json()
        user_id = data.get('userId')
        
        if not user_id:
            return jsonify({'error': 'userId required'}), 400
        
        update_data = {}
        if 'firstName' in data:
            update_data['first_name'] = data['firstName']
        if 'lastName' in data:
            update_data['last_name'] = data['lastName']
        if 'username' in data:
            # Check if username is already taken by another user
            existing = select('users', filters={'username': data['username']})
            if existing and existing[0]['id'] != user_id:
                return jsonify({'error': 'Username already taken'}), 400
            update_data['username'] = data['username']
        if 'email' in data:
            # Check if email is already taken by another user
            existing = select('users', filters={'email': data['email']})
            if existing and existing[0]['id'] != user_id:
                return jsonify({'error': 'Email already taken'}), 400
            update_data['email'] = data['email']
        
        if not update_data:
            return jsonify({'error': 'No fields to update'}), 400
        
        result = update(
            'users',
            update_data,
            filters={'id': user_id}
        )
        
        return jsonify({'success': True}), 200
        
    except Exception as e:
        print(f"Error in update_profile: {e}")
        return jsonify({'error': str(e)}), 500

@auth_bp.route('/user.updatePassword', methods=['PUT'])
def update_password():
    """Update user password"""
    try:
        data = request.get_json()
        user_id = data.get('userId')
        password = data.get('password')
        
        if not all([user_id, password]):
            return jsonify({'error': 'userId and password required'}), 400
        
        result = update(
            'users',
            {'password': password},
            filters={'id': user_id}
        )
        
        return jsonify({'success': True}), 200
        
    except Exception as e:
        print(f"Error in update_password: {e}")
        return jsonify({'error': str(e)}), 500

@auth_bp.route('/user.updateStars', methods=['PUT'])
def update_stars():
    """Update user stars"""
    try:
        data = request.get_json()
        user_id = data.get('userId')
        stars = data.get('stars')
        
        if not all([user_id, stars is not None]):
            return jsonify({'error': 'userId and stars required'}), 400
        
        result = update(
            'users',
            {'stars': stars},
            filters={'id': user_id}
        )
        
        return jsonify({'success': True}), 200
        
    except Exception as e:
        print(f"Error in update_stars: {e}")
        return jsonify({'error': str(e)}), 500

@auth_bp.route('/user.updatePoints', methods=['PUT'])
def update_points():
    """Update user total points (absolute value)"""
    try:
        data = request.get_json()
        user_id = data.get('userId')
        total_points = data.get('totalPoints')
        
        if not all([user_id, total_points is not None]):
            return jsonify({'error': 'userId and totalPoints required'}), 400
        
        result = update(
            'users',
            {'total_points': total_points},
            filters={'id': user_id}
        )
        
        return jsonify({'success': True}), 200
        
    except Exception as e:
        print(f"Error in update_points: {e}")
        return jsonify({'error': str(e)}), 500

@auth_bp.route('/user.awardPoints', methods=['POST'])
def award_points():
    """Award points to user (can be positive or negative)"""
    try:
        data = request.get_json()
        user_id = data.get('userId')
        points = data.get('points')
        
        if not all([user_id, points is not None]):
            return jsonify({'error': 'userId and points required'}), 400
        
        # Get current points
        user = select('users', filters={'id': user_id}, single=True)
        
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        current_points = user.get('total_points', 0)
        new_points = current_points + points
        
        # Don't let points go below 0
        if new_points < 0:
            new_points = 0
        
        # Update points
        result = update(
            'users',
            {'total_points': new_points},
            filters={'id': user_id}
        )
        
        return jsonify({
            'success': True,
            'newTotal': new_points
        }), 200
        
    except Exception as e:
        print(f"Error in award_points: {e}")
        return jsonify({'error': str(e)}), 500