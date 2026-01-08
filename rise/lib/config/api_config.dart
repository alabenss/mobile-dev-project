// lib/config/api_config.dart
class ApiConfig {
  // Change this to your deployed backend URL after deployment
  static const String BASE_URL = 'https://rise-l52y.onrender.com';

  // Auth endpoints
  static const String AUTH_LOGIN = '/user.login';
  static const String AUTH_REGISTER = '/user.register';
  static const String AUTH_LOGOUT = '/user.logout';
  static const String AUTH_VERIFY_TOKEN = '/user.verifyToken';

  // User endpoints
  static const String USER_PROFILE = '/user.profile';
  static const String USER_UPDATE = '/user.updateProfile';
  static const String USER_UPDATE_PASSWORD = '/user.updatePassword';
  static const String USER_UPDATE_STARS = '/user.updateStars';
  static const String USER_UPDATE_POINTS = '/user.updatePoints';
  static const String USER_AWARD_POINTS = '/user.awardPoints';
  static const String USER_STATS = '/user.stats';

  // App Lock endpoints
  static const String APP_LOCK_GET = '/lock.get';
  static const String APP_LOCK_SAVE = '/lock.save';
  static const String APP_LOCK_REMOVE = '/lock.remove';

  // Habits endpoints
  static const String HABITS_GET = '/habits.get';
  static const String HABITS_ADD = '/habits.add';
  static const String HABITS_UPDATE = '/habits.update';
  static const String HABITS_UPDATE_STATUS = '/habits.updateStatus';
  static const String HABITS_DELETE = '/habits.delete';
  static const String HABITS_GET_BY_TITLE = '/habits.getByTitle';
  static const String HABITS_CHECK_EXISTS = '/habits.checkExists';
  static const String HABITS_GET_COMPLETED = '/habits.getCompleted';
  static const String HABITS_RESTORE_STREAK = '/habits.restoreStreak';
  static const String HABITS_CHECK_RESET = '/habits.checkReset';
  static const String HABITS_RESET_DAILY = '/habits.resetDaily';

  // Moods endpoints
  static const String MOODS_TODAY = '/moods.today';
  static const String MOODS_SAVE = '/moods.save';
  static const String MOODS_DELETE = '/moods.delete';
  static const String MOODS_GET_ALL = '/moods.getAll';
  static const String MOODS_GET_BY_MONTH = '/moods.getByMonth';

  // Home endpoints
  static const String HOME_STATUS_GET = '/home.status';
  static const String HOME_STATUS_SAVE = '/home.status';
  static const String HOME_INCREMENT_WATER = '/home.incrementWater';
  static const String HOME_DECREMENT_WATER = '/home.decrementWater';
  static const String HOME_UPDATE_DETOX = '/home.updateDetox';
  static const String HOME_GET_RANGE = '/home.getRange';

  // Journals endpoints
  static const String JOURNALS_GET = '/journals.get';
  static const String JOURNALS_ADD = '/journals.add';
  static const String JOURNALS_UPDATE = '/journals.update';
  static const String JOURNALS_DELETE = '/journals.delete';

  // Plant endpoints
  static const String PLANT_GET = '/plant.get';
  static const String PLANT_UPDATE = '/plant.update';
  static const String PLANT_RESET = '/plant.reset';

  // ✅ Articles endpoints (NEW)
  static const String ARTICLES_GET_ALL = '/articles.getAll';
  static const String ARTICLES_GET = '/articles.get';

  // Timeout settings
  static const Duration CONNECTION_TIMEOUT = Duration(seconds: 30);
  static const Duration RECEIVE_TIMEOUT = Duration(seconds: 30);
}
