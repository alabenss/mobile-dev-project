// lib/screens/welcome_screens/welcome_provider.dart
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeProvider {
  static const String _welcomeKey = 'hasSeenWelcome';

  /// Check if user has already seen welcome screens
  /// This is app-level (not per user) - shown once when app is first installed
  static Future<bool> shouldShowWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenWelcome = prefs.getBool(_welcomeKey) ?? false;
    return !hasSeenWelcome;
  }

  /// Mark welcome screens as seen (called after completing welcome flow)
  static Future<void> markWelcomeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_welcomeKey, true);
  }

  /// Reset (for testing purposes)
  static Future<void> resetWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_welcomeKey);
  }
}