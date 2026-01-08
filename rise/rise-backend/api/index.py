from flask import Flask, jsonify
from flask_cors import CORS
from api.routes.auth import auth_bp
from api.routes.app_lock import app_lock_bp  
from api.routes.plant import plant_bp  
from api.routes.journals import journals_bp
from api.routes.habits import habits_bp
from api.routes.moods import moods_bp
from api.routes.home import home_bp
import logging

from api.routes.articles import articles_bp
app.register_blueprint(articles_bp)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

app = Flask(__name__)

# Enable CORS for all routes
CORS(app, resources={
    r"/*": {
        "origins": "*",
        "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
        "allow_headers": ["Content-Type"]
    }
})

# Register all blueprints
app.register_blueprint(auth_bp)
app.register_blueprint(app_lock_bp)  
app.register_blueprint(plant_bp)  
app.register_blueprint(journals_bp)
app.register_blueprint(habits_bp)
app.register_blueprint(moods_bp)
app.register_blueprint(home_bp)


# Error handlers
@app.errorhandler(404)
def not_found(error):
    return jsonify({'success': False, 'error': 'Endpoint not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'success': False, 'error': 'Internal server error'}), 500

@app.route('/')
def index():
    return {
        'message': 'Rise App Backend API',
        'version': '1.0',
        'status': 'running',
        'endpoints': {
            'auth': ['/user.register', '/user.login', '/user.profile', '/user.updateProfile', 
                     '/user.updatePassword', '/user.updateStars', '/user.updatePoints', '/user.awardPoints'],
            'app_lock': ['/lock.get', '/lock.save', '/lock.remove'],
            'plant': ['/plant.get', '/plant.update', '/plant.reset'],
            'journals': ['/journals.get', '/journals.add', '/journals.update', '/journals.delete'],
            'habits': ['/habits.get', '/habits.add', '/habits.update', '/habits.updateStatus', 
                       '/habits.delete', '/habits.getByTitle', '/habits.checkExists', 
                       '/habits.getCompleted', '/habits.restoreStreak', '/habits.checkReset', '/habits.resetDaily'],
            'moods': ['/moods.today', '/moods.save', '/moods.delete', '/moods.getAll', '/moods.getByMonth'],
            'home': ['/home.status (GET/POST)', '/home.incrementWater', '/home.decrementWater', 
                     '/home.updateDetox', '/home.getRange']
        }
    }

@app.route('/health')
def health():
    return {'status': 'healthy', 'timestamp': __import__('datetime').datetime.now().isoformat()}, 200


from api.database import select

@app.route('/debug/supabase')
def debug_supabase():
    try:
        users = select('users', columns='id,name,email', filters=None)
        return {'success': True, 'count': len(users), 'sample': users[:3]}, 200
    except Exception as e:
        return {'success': False, 'error': str(e)}, 500


# For local development
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)