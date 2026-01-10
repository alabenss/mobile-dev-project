from flask import Blueprint, request, jsonify
from ..database import select, insert, update
from datetime import datetime

plant_bp = Blueprint('plant', __name__)

@plant_bp.route('/plant.get', methods=['GET'])
def get_plant():
    try:
        user_id = request.args.get('userId')
        if not user_id:
            return jsonify({'error': 'userId required'}), 400

        plant = select(
            'plant_progress',
            filters={'user_id': int(user_id)},
            single=True
        )

        if not plant:
            # Auto-create plant row
            insert('plant_progress', {
                'user_id': user_id,
                'water': 0,
                'sunlight': 0,
                'stage': 0,
                'updated_at': datetime.now().isoformat()
            })
            plant = {
                'water': 0,
                'sunlight': 0,
                'stage': 0
            }

        user = select(
            'users',
            filters={'id': int(user_id)},
            single=True
        )

        return jsonify({
            'success': True,
            'plant': {
                'water': plant['water'],
                'sunlight': plant['sunlight'],
                'stage': plant['stage'],
            },
            'points': user.get('total_points', 0),
            'stars': user.get('stars', 0)
        }), 200

    except Exception as e:
        print(f'plant.get error: {e}')
        return jsonify({'error': str(e)}), 500


@plant_bp.route('/plant.update', methods=['POST'])
def update_plant():
    try:
        data = request.get_json()

        user_id = data.get('userId')
        water = data.get('water')
        sunlight = data.get('sunlight')
        stage = data.get('stage')
        points = data.get('points')
        stars = data.get('stars')

        if not all([user_id, water is not None, sunlight is not None, stage is not None]):
            return jsonify({'error': 'Missing fields'}), 400

        # Update plant
        update(
            'plant_progress',
            {
                'water': water,
                'sunlight': sunlight,
                'stage': stage,
                'updated_at': datetime.now().isoformat()
            },
            filters={'user_id': user_id}
        )

        # Update user points / stars
        if points is not None or stars is not None:
            update_data = {}
            if points is not None:
                update_data['total_points'] = points
            if stars is not None:
                update_data['stars'] = stars

            update('users', update_data, filters={'id': user_id})

        return jsonify({'success': True}), 200

    except Exception as e:
        print(f'plant.update error: {e}')
        return jsonify({'error': str(e)}), 500


@plant_bp.route('/plant.reset', methods=['POST'])
def reset_plant():
    try:
        data = request.get_json()
        user_id = data.get('userId')

        if not user_id:
            return jsonify({'error': 'userId required'}), 400

        update(
            'plant_progress',
            {'water': 0, 'sunlight': 0, 'stage': 0},
            filters={'user_id': user_id}
        )

        return jsonify({'success': True}), 200

    except Exception as e:
        print(f'plant.reset error: {e}')
        return jsonify({'error': str(e)}), 500
