from flask import Blueprint, request, jsonify
from functools import wraps
import jwt
from ..database import select, insert, update, supabase

auth_bp = Blueprint('auth', __name__)

def verify_token(f):
    """Decorator to verify JWT token"""
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization')
        
        if not token:
            return jsonify({'error': 'No token provided'}), 401
        
        try:
            # Remove 'Bearer ' prefix if present
            if token.startswith('Bearer '):
                token = token[7:]
            
            # Verify token with Supabase
            user = supabase.auth.get_user(token)
            
            if not user:
                return jsonify({'error': 'Invalid token'}), 401
            
            # Add user to request context
            request.current_user = user
            
        except Exception as e:
            print(f"Token verification error: {e}")
            return jsonify({'error': 'Invalid token'}), 401
        
        return f(*args, **kwargs)
    
    return decorated

@auth_bp.route('/user.register', methods=['POST'])
def register():
    """Register a new user with Supabase Auth"""
    try:
        data = request.get_json()
        first_name = data.get('firstName')
        last_name = data.get('lastName')
        username = data.get('username')
        email = data.get('email')
        password = data.get('password')
        
        if not all([first_name, last_name, username, email, password]):
            return jsonify({'error': 'Missing required fields'}), 400
        
        # Check if username exists in our users table
        existing_username = select('users', filters={'username': username})
        if existing_username:
            return jsonify({'error': 'Username already exists'}), 400
        
        # Create user in Supabase Auth
        auth_response = supabase.auth.sign_up({
            'email': email,
            'password': password,
            'options': {
                'data': {
                    'first_name': first_name,
                    'last_name': last_name,
                    'username': username
                }
            }
        })
        
        if not auth_response.user:
            return jsonify({'error': 'Failed to create user'}), 500
        
        # Get the created user from our users table (created by trigger)
        user_record = select('users', filters={'auth_id': str(auth_response.user.id)}, single=True)
        
        # If trigger didn't work, create manually
        if not user_record:
            user_record = insert('users', {
                'auth_id': str(auth_response.user.id),
                'first_name': first_name,
                'last_name': last_name,
                'username': username,
                'email': email,
                'total_points': 0,
                'stars': 0
            })[0]
        
        return jsonify({
            'success': True,
            'user': user_record,
            'session': {
                'access_token': auth_response.session.access_token,
                'refresh_token': auth_response.session.refresh_token,
                'expires_at': auth_response.session.expires_at
            }
        }), 201
        
    except Exception as e:
        print(f"Error in register: {e}")
        error_msg = str(e)
        if 'already registered' in error_msg.lower():
            return jsonify({'error': 'Email already exists'}), 400
        return jsonify({'error': error_msg}), 500

@auth_bp.route('/user.login', methods=['POST'])
def login():
    """Login user with Supabase Auth"""
    try:
        data = request.get_json()
        identifier = data.get('email')  # can be email or username
        password = data.get('password')

        if not all([identifier, password]):
            return jsonify({'error': 'Missing credentials'}), 400

        # Check if identifier is username, then get email
        email = identifier
        if '@' not in identifier:
            # It's a username, get the email
            user_record = select('users', columns='email', filters={'username': identifier}, single=True)
            if not user_record:
                return jsonify({'error': 'Invalid credentials'}), 401
            email = user_record['email']

        # Sign in with Supabase Auth
        auth_response = supabase.auth.sign_in_with_password({
            'email': email,
            'password': password
        })

        if not auth_response.user:
            return jsonify({'error': 'Invalid credentials'}), 401

        # Get user data from our users table
        user_record = select(
            'users',
            columns='id, first_name, last_name, username, email, total_points, stars, created_at',
            filters={'auth_id': str(auth_response.user.id)},
            single=True
        )

        if not user_record:
            return jsonify({'error': 'User profile not found'}), 404

        return jsonify({
            'success': True,
            'user': user_record,
            'session': {
                'access_token': auth_response.session.access_token,
                'refresh_token': auth_response.session.refresh_token,
                'expires_at': auth_response.session.expires_at
            }
        }), 200

    except Exception as e:
        print(f"Error in login: {e}")
        return jsonify({'error': 'Invalid credentials'}), 401

@auth_bp.route('/user.logout', methods=['POST'])
@verify_token
def logout():
    """Logout user from Supabase Auth"""
    try:
        supabase.auth.sign_out()
        return jsonify({'success': True}), 200
    except Exception as e:
        print(f"Error in logout: {e}")
        return jsonify({'error': str(e)}), 500

@auth_bp.route('/user.refresh', methods=['POST'])
def refresh_token():
    """Refresh access token using refresh token"""
    try:
        data = request.get_json()
        refresh_token = data.get('refreshToken')
        
        if not refresh_token:
            return jsonify({'error': 'Refresh token required'}), 400
        
        # Refresh session
        auth_response = supabase.auth.refresh_session(refresh_token)
        
        if not auth_response.session:
            return jsonify({'error': 'Failed to refresh token'}), 401
        
        return jsonify({
            'success': True,
            'session': {
                'access_token': auth_response.session.access_token,
                'refresh_token': auth_response.session.refresh_token,
                'expires_at': auth_response.session.expires_at
            }
        }), 200
        
    except Exception as e:
        print(f"Error refreshing token: {e}")
        return jsonify({'error': str(e)}), 401

@auth_bp.route('/user.profile', methods=['GET'])
@verify_token
def get_profile():
    """Get user profile (requires authentication)"""
    try:
        # Get auth_id from verified token
        auth_id = request.current_user.user.id
        
        result = select(
            'users',
            columns='id, first_name, last_name, username, email, total_points, stars, created_at',
            filters={'auth_id': str(auth_id)},
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
@verify_token
def update_profile():
    """Update user profile (requires authentication)"""
    try:
        data = request.get_json()
        auth_id = request.current_user.user.id
        
        # Get current user
        current_user = select('users', filters={'auth_id': str(auth_id)}, single=True)
        if not current_user:
            return jsonify({'error': 'User not found'}), 404
        
        update_data = {}
        
        if 'firstName' in data:
            update_data['first_name'] = data['firstName']
        if 'lastName' in data:
            update_data['last_name'] = data['lastName']
        if 'username' in data:
            # Check if username is already taken by another user
            existing = select('users', filters={'username': data['username']})
            if existing and existing[0]['id'] != current_user['id']:
                return jsonify({'error': 'Username already taken'}), 400
            update_data['username'] = data['username']
        if 'email' in data:
            # Check if email is already taken
            existing = select('users', filters={'email': data['email']})
            if existing and existing[0]['id'] != current_user['id']:
                return jsonify({'error': 'Email already taken'}), 400
            update_data['email'] = data['email']
            
            # Also update email in Supabase Auth
            try:
                supabase.auth.update_user({'email': data['email']})
            except Exception as e:
                print(f"Error updating email in Supabase Auth: {e}")
        
        if not update_data:
            return jsonify({'error': 'No fields to update'}), 400
        
        result = update('users', update_data, filters={'auth_id': str(auth_id)})
        
        return jsonify({'success': True}), 200
        
    except Exception as e:
        print(f"Error in update_profile: {e}")
        return jsonify({'error': str(e)}), 500

@auth_bp.route('/user.updatePassword', methods=['PUT'])
@verify_token
def update_password():
    """Update user password in Supabase Auth"""
    try:
        data = request.get_json()
        password = data.get('password')
        
        if not password:
            return jsonify({'error': 'Password required'}), 400
        
        if len(password) < 6:
            return jsonify({'error': 'Password must be at least 6 characters'}), 400
        
        # Update password in Supabase Auth
        supabase.auth.update_user({'password': password})
        
        return jsonify({'success': True}), 200
        
    except Exception as e:
        print(f"Error in update_password: {e}")
        return jsonify({'error': str(e)}), 500

@auth_bp.route('/user.updateStars', methods=['PUT'])
@verify_token
def update_stars():
    """Update user stars"""
    try:
        data = request.get_json()
        stars = data.get('stars')
        auth_id = request.current_user.user.id
        
        if stars is None:
            return jsonify({'error': 'Stars required'}), 400
        
        result = update('users', {'stars': stars}, filters={'auth_id': str(auth_id)})
        
        return jsonify({'success': True}), 200
        
    except Exception as e:
        print(f"Error in update_stars: {e}")
        return jsonify({'error': str(e)}), 500

@auth_bp.route('/user.updatePoints', methods=['PUT'])
@verify_token
def update_points():
    """Update user total points (absolute value)"""
    try:
        data = request.get_json()
        total_points = data.get('totalPoints')
        auth_id = request.current_user.user.id
        
        if total_points is None:
            return jsonify({'error': 'totalPoints required'}), 400
        
        result = update('users', {'total_points': total_points}, filters={'auth_id': str(auth_id)})
        
        return jsonify({'success': True}), 200
        
    except Exception as e:
        print(f"Error in update_points: {e}")
        return jsonify({'error': str(e)}), 500

@auth_bp.route('/user.awardPoints', methods=['POST'])
@verify_token
def award_points():
    """Award points to user (can be positive or negative)"""
    try:
        data = request.get_json()
        points = data.get('points')
        auth_id = request.current_user.user.id
        
        if points is None:
            return jsonify({'error': 'Points required'}), 400
        
        # Get current points
        user = select('users', filters={'auth_id': str(auth_id)}, single=True)
        
        if not user:
            return jsonify({'error': 'User not found'}), 404
        
        current_points = user.get('total_points', 0)
        new_points = current_points + points
        
        # Don't let points go below 0
        if new_points < 0:
            new_points = 0
        
        # Update points
        result = update('users', {'total_points': new_points}, filters={'auth_id': str(auth_id)})
        
        return jsonify({
            'success': True,
            'newTotal': new_points
        }), 200
        
    except Exception as e:
        print(f"Error in award_points: {e}")
        return jsonify({'error': str(e)}), 500