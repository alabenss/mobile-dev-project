import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_state.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState()) {
    _setupAuthListener();
  }

  final ApiService _api = ApiService.instance;
  SupabaseClient get _supabase => Supabase.instance.client;

  /* ----------------------------- ERROR HANDLING ----------------------------- */

  String _mapErrorToMessage(Object e) {
    final error = e.toString().toLowerCase();

    if (error.contains('401') || error.contains('invalid credentials')) {
      return 'Invalid credentials. Please check your email or password.';
    }
    if (error.contains('email') && error.contains('exist')) {
      return 'This email is already registered.';
    }
    if (error.contains('username') && error.contains('exist')) {
      return 'This username is already taken.';
    }
    if (error.contains('socket') ||
        error.contains('failed host lookup') ||
        error.contains('no address associated')) {
      return 'No internet connection. Please check your network.';
    }
    if (error.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    if (error.contains('500') || error.contains('server')) {
      return 'Server error. Please try again later.';
    }
    return 'Something went wrong. Please try again.';
  }

  /* ----------------------------- AUTH LISTENER ------------------------------ */

  void _setupAuthListener() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session == null) {
        emit(const AuthState(isAuthenticated: false));
      } else {
        _loadUserProfile();
      }
    });
  }

  /* ----------------------------- LOAD PROFILE ------------------------------- */

  Future<void> _loadUserProfile() async {
    try {
      final response = await _api.get(ApiConfig.USER_PROFILE);

      if (response['success'] == true && response['user'] != null) {
        final user = User.fromMap(response['user']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', user.id);

        emit(state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: _mapErrorToMessage(e),
      ));
    }
  }

  /* ----------------------------- CHECK AUTH -------------------------------- */

  Future<void> checkAuthStatus() async {
    emit(state.copyWith(isLoading: true));

    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        await _loadUserProfile();
        return;
      }

      // fallback → stored userId
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        emit(state.copyWith(isLoading: false, isAuthenticated: false));
        return;
      }

      final response = await _api.get(
        ApiConfig.USER_PROFILE,
        params: {'userId': userId.toString()},
      );

      if (response['success'] == true && response['user'] != null) {
        emit(state.copyWith(
          user: User.fromMap(response['user']),
          isAuthenticated: true,
          isLoading: false,
        ));
      } else {
        await prefs.remove('userId');
        emit(state.copyWith(isLoading: false, isAuthenticated: false));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: _mapErrorToMessage(e),
      ));
    }
  }

  /* ----------------------------- AUTH ACTIONS ------------------------------- */

  Future<bool> signUp(
    String firstName,
    String lastName,
    String username,
    String email,
    String password,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final response = await _api.post(ApiConfig.AUTH_REGISTER, {
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'password': password,
      });

      if (response['success'] != true) {
        emit(state.copyWith(
          isLoading: false,
          error: response['message'] ?? 'Registration failed',
        ));
        return false;
      }

      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      await _loadUserProfile();
      return true;
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: _mapErrorToMessage(e),
      ));
      return false;
    }
  }

  Future<bool> login(String identifier, String password) async {
    emit(state.copyWith(isLoading: true));

    try {
      final response = await _api.post(ApiConfig.AUTH_LOGIN, {
        'email': identifier,
        'password': password,
      });

      if (response['success'] != true) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Invalid credentials',
        ));
        return false;
      }

      if (response['session'] != null) {
        await _supabase.auth.setSession(
          response['session']['access_token'],
        );
      }

      await _loadUserProfile();
      return true;
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: _mapErrorToMessage(e),
      ));
      return false;
    }
  }

  /* ----------------------------- USER UPDATE ------------------------------- */

  Future<void> refreshUserData() async {
    if (state.user == null) return;
    await _loadUserProfile();
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    emit(const AuthState());
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }
}
