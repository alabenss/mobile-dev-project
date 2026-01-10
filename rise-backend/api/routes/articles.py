from flask import Blueprint, request, jsonify
from ..database import select

articles_bp = Blueprint('articles', __name__)

@articles_bp.route('/articles.getAll', methods=['GET'])
def get_all_articles():
    """Get all published articles (light list)"""
    try:
        lang = request.args.get('lang', 'en')

        rows = select(
            'articles',
            columns='id, slug, title, summary, hero_image_url, language, is_published, updated_at'
        ) or []

        rows = [r for r in rows if r.get('is_published') is True and r.get('language') == lang]
        rows.sort(key=lambda x: x.get('updated_at') or '', reverse=True)

        return jsonify({'success': True, 'articles': rows}), 200

    except Exception as e:
        print(f"articles.getAll error: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500


@articles_bp.route('/articles.get', methods=['GET'])
def get_article():
    """Get one published article by slug (full content)"""
    try:
        slug = request.args.get('slug')
        lang = request.args.get('lang', 'en')

        if not slug:
            return jsonify({'success': False, 'error': 'slug required'}), 400

        row = select(
            'articles',
            columns='id, slug, title, summary, hero_image_url, content, language, is_published, updated_at',
            filters={'slug': slug, 'language': lang},
            single=True
        )

        if not row or row.get('is_published') is not True or row.get('language') != lang:
            return jsonify({'success': False, 'error': 'Article not found'}), 404

        return jsonify({'success': True, 'article': row}), 200

    except Exception as e:
        print(f"articles.get error: {e}")
        return jsonify({'success': False, 'error': str(e)}), 500
