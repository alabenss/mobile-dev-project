// lib/config/api_config.dart

class ApiConfig {
  // Change this to your deployed backend URL after deployment
  static const String BASE_URL = 'http://10.0.2.2:5000';
  // For physical device on same network: 'http://YOUR_COMPUTER_IP:5000'
  // For production: 'https://your-app.vercel.app'
  
  // ========== Auth Endpoints ==========
  static const String AUTH_REGISTER = '/user.register';
  static const String AUTH_LOGIN = '/user.login';
  static const String USER_PROFILE = '/user.profile';
  
  // ========== Journal Endpoints ==========
  static const String JOURNALS_GET = '/journals.get';
  static const String JOURNALS_ADD = '/journals.add';
  static const String JOURNALS_UPDATE = '/journals.update';
  static const String JOURNALS_DELETE = '/journals.delete';
  
  // ========== Habit Endpoints ==========
  static const String HABITS_GET = '/habits.get';
  static const String HABITS_ADD = '/habits.add';
  static const String HABITS_UPDATE = '/habits.update';
  static const String HABITS_UPDATE_STATUS = '/habits.updateStatus';
  static const String HABITS_DELETE = '/habits.delete';
  static const String HABITS_GET_BY_TITLE = '/habits.getByTitle';
  static const String HABITS_CHECK_EXISTS = '/habits.checkExists';
  static const String HABITS_GET_COMPLETED = '/habits.getCompleted';
  
  // ========== Mood Endpoints ==========
  static const String MOODS_TODAY = '/moods.today';
  static const String MOODS_SAVE = '/moods.save';
  static const String MOODS_DELETE = '/moods.delete';
  static const String MOODS_GET_ALL = '/moods.getAll';
  static const String MOODS_GET_BY_MONTH = '/moods.getByMonth';
  
  // ========== Home Status Endpoints ==========
  static const String HOME_STATUS_GET = '/home.status';
  static const String HOME_STATUS_SAVE = '/home.status';
  static const String HOME_INCREMENT_WATER = '/home.incrementWater';
  static const String HOME_DECREMENT_WATER = '/home.decrementWater';
  static const String HOME_UPDATE_DETOX = '/home.updateDetox';
  static const String HOME_GET_RANGE = '/home.getRange';
}