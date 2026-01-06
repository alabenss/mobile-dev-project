from flask import Blueprint, request, jsonify
from ..database import select, insert, update, delete
import json
from datetime import datetime

journals_bp = Blueprint('journals', __name__)

@journals_bp.route('/journals.get', methods=['GET'])
def get_journals():
    """Get all journals for a user"""
    try:
        user_id = request.args.get('userId')
        month = request.args.get('month')  # Optional filter
        year = request.args.get('year')    # Optional filter
        
        if not user_id:
            return jsonify({'error': 'userId required'}), 400
        
        # Get all journals for user
        result = select(
            'journals',
            columns='id, user_id, date, time, mood, text, title, image_path, voice_path, background_image, font_family, text_color, font_size, attached_images, stickers',
            filters={'user_id': int(user_id)}
        )
        
        # Convert to list of dicts and sort by date (newest first)
        journals = list(result) if result else []
        journals.sort(key=lambda x: x.get('date', ''), reverse=True)
        
        # Optional: Filter by month/year on backend
        if month and year:
            month = int(month)
            year = int(year)
            journals = [
                j for j in journals 
                if datetime.fromisoformat(j['date'].replace('Z', '+00:00')).month == month 
                and datetime.fromisoformat(j['date'].replace('Z', '+00:00')).year == year
            ]
        
        return jsonify({
            'success': True,
            'journals': journals
        }), 200
        
    except Exception as e:
        print(f"Error in get_journals: {e}")
        return jsonify({'error': str(e)}), 500

@journals_bp.route('/journals.add', methods=['POST'])
def add_journal():
    """Add a new journal entry"""
    try:
        data = request.get_json()
        
        journal_data = {
            'user_id': data.get('userId'),
            'date': data.get('date'),
            'time': data.get('time'),
            'mood': data.get('mood'),
            'text': data.get('text'),
            'title': data.get('title'),
            'voice_path': data.get('voicePath'),
            'background_image': data.get('backgroundImage'),
            'font_family': data.get('fontFamily'),
            'text_color': data.get('textColor'),
            'font_size': data.get('fontSize'),
            'attached_images': data.get('attachedImages'),  # Supabase handles JSONB
            'stickers': data.get('stickers')  # Supabase handles JSONB
        }
        
        result = insert('journals', journal_data)
        
        return jsonify({
            'success': True,
            'journalId': result[0]['id'] if result else None
        }), 201
        
    except Exception as e:
        print(f"Error in add_journal: {e}")
        return jsonify({'error': str(e)}), 500

@journals_bp.route('/journals.update', methods=['PUT'])
def update_journal():
    """Update a journal entry"""
    try:
        data = request.get_json()
        journal_id = data.get('id')
        user_id = data.get('userId')
        
        if not journal_id or not user_id:
            return jsonify({'error': 'id and userId required'}), 400
        
        update_data = {
            'text': data.get('text'),
            'title': data.get('title'),
            'mood': data.get('mood'),
            'background_image': data.get('backgroundImage'),
            'font_family': data.get('fontFamily'),
            'text_color': data.get('textColor'),
            'font_size': data.get('fontSize'),
            'attached_images': data.get('attachedImages'),
            'stickers': data.get('stickers')
        }
        
        result = update(
            'journals',
            update_data,
            filters={'id': journal_id, 'user_id': user_id}
        )
        
        return jsonify({'success': True}), 200
        
    except Exception as e:
        print(f"Error in update_journal: {e}")
        return jsonify({'error': str(e)}), 500

@journals_bp.route('/journals.delete', methods=['DELETE'])
def delete_journal():
    """Delete a journal entry"""
    try:
        journal_id = request.args.get('id')
        user_id = request.args.get('userId')
        
        if not journal_id or not user_id:
            return jsonify({'error': 'id and userId required'}), 400
        
        result = delete(
            'journals',
            filters={'id': int(journal_id), 'user_id': int(user_id)}
        )
        
        return jsonify({'success': True}), 200
        
    except Exception as e:
        print(f"Error in delete_journal: {e}")
        return jsonify({'error': str(e)}), 500