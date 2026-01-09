// lib/screens/welcome_screens/welcome_provider.dart
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeProvider {
  static const String _welcomeKey = 'hasSeenWelcome';
  static const String _authKey = 'hasLoggedInBefore'; // NEW

  /// Check if user has already seen welcome screens AND never logged in
  static Future<bool> shouldShowWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if user has seen welcome screens
    final hasSeenWelcome = prefs.getBool(_welcomeKey) ?? false;
    
    // Check if user has ever logged in (NEW)
    final hasLoggedInBefore = prefs.getBool(_authKey) ?? false;
    
    // Show welcome ONLY if never seen welcome AND never logged in
    return !hasSeenWelcome && !hasLoggedInBefore;
  }

  /// Mark welcome screens as seen
  static Future<void> markWelcomeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_welcomeKey, true);
  }

  /// Mark that user has logged in (call this after successful login/signup)
  static Future<void> markUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_authKey, true);
  }

  /// Reset (for testing purposes)
  static Future<void> resetWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_welcomeKey);
    await prefs.remove(_authKey);
  }
}