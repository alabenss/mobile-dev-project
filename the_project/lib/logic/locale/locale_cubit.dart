import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleState {
  final Locale? locale;
  final bool isSystemDefault;

  const LocaleState({
    this.locale,
    this.isSystemDefault = true,
  });

  LocaleState copyWith({
    Locale? locale,
    bool? isSystemDefault,
  }) {
    return LocaleState(
      locale: locale ?? this.locale,
      isSystemDefault: isSystemDefault ?? this.isSystemDefault,
    );
  }
}

class LocaleCubit extends Cubit<LocaleState> {
  static const String _localeKey = 'app_locale';
  static const String _isSystemDefaultKey = 'is_system_default';

  LocaleCubit() : super(const LocaleState(locale: null, isSystemDefault: true)) {
    _loadSavedLocale();
  }

  /// Initialize with system locale
  void initializeWithSystemLocale(Locale systemLocale) {
    if (state.isSystemDefault) {
      emit(LocaleState(locale: systemLocale, isSystemDefault: true));
    }
  }

  /// Load saved locale from SharedPreferences
  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isSystemDefault = prefs.getBool(_isSystemDefaultKey) ?? true;
      
      if (isSystemDefault) {
        // Keep null to signal system default should be used
        emit(const LocaleState(locale: null, isSystemDefault: true));
      } else {
        // Use saved locale
        final languageCode = prefs.getString(_localeKey);
        if (languageCode != null) {
          emit(LocaleState(
            locale: Locale(languageCode),
            isSystemDefault: false,
          ));
        }
      }
    } catch (e) {
      print('Error loading locale: $e');
    }
  }

  /// Change to a specific locale
  Future<void> changeLocale(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, languageCode);
      await prefs.setBool(_isSystemDefaultKey, false);
      
      emit(LocaleState(
        locale: Locale(languageCode),
        isSystemDefault: false,
      ));
    } catch (e) {
      print('Error saving locale: $e');
    }
  }

  /// Reset to system default locale
  Future<void> useSystemDefault() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isSystemDefaultKey, true);
      await prefs.remove(_localeKey);
      
      // Set locale to null to signal system default
      emit(const LocaleState(
        locale: null,
        isSystemDefault: true,
      ));
    } catch (e) {
      print('Error resetting to system locale: $e');
    }
  }

  /// Get available languages
  static List<Map<String, String>> get availableLanguages => [
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'fr', 'name': 'French', 'nativeName': 'Français'},
    {'code': 'ar', 'name': 'Arabic', 'nativeName': 'العربية'},
  ];
}