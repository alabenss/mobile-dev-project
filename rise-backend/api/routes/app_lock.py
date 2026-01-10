from flask import Blueprint, request, jsonify
from ..database import select, insert, update, delete

app_lock_bp = Blueprint('app_lock', __name__)

@app_lock_bp.route('/lock.get', methods=['GET'])
def get_lock():
    try:
        user_id = request.args.get('userId')

        if not user_id:
            return jsonify({'error': 'userId required'}), 400

        lock = select(
            'app_locks',
            filters={'user_id': int(user_id)},
            single=True
        )

        if not lock:
            return jsonify({'success': True, 'lock': None}), 200

        return jsonify({
            'success': True,
            'lock': {
                'lockType': lock['lock_type'],
                'lockValue': lock['lock_value']
            }
        }), 200

    except Exception as e:
        print(f'get_lock error: {e}')
        return jsonify({'error': str(e)}), 500

@app_lock_bp.route('/lock.save', methods=['POST'])
def save_lock():
    try:
        data = request.get_json()
        user_id = data.get('userId')
        lock_type = data.get('lockType')
        lock_value = data.get('lockValue')

        if not all([user_id, lock_type, lock_value]):
            return jsonify({'error': 'Missing fields'}), 400

        existing = select(
            'app_locks',
            filters={'user_id': user_id},
            single=True
        )

        if existing:
            update(
                'app_locks',
                {
                    'lock_type': lock_type,
                    'lock_value': lock_value,
                },
                filters={'user_id': user_id}
            )
        else:
            insert('app_locks', {
                'user_id': user_id,
                'lock_type': lock_type,
                'lock_value': lock_value,
            })

        return jsonify({'success': True}), 200

    except Exception as e:
        print(f'save_lock error: {e}')
        return jsonify({'error': str(e)}), 500


@app_lock_bp.route('/lock.remove', methods=['DELETE'])
def remove_lock():
    try:
        # FIXED: Get userId from query params instead of request body
        user_id = request.args.get('userId')

        if not user_id:
            return jsonify({'error': 'userId required'}), 400

        delete(
            'app_locks',
            filters={'user_id': int(user_id)}
        )

        return jsonify({'success': True}), 200

    except Exception as e:
        print(f'remove_lock error: {e}')
        return jsonify({'error': str(e)}), 500