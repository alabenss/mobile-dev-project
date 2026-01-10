import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_state.dart' as app_auth;
import '../../models/user_model.dart' as app_user;

import '../../services/api_service.dart';
import '../../config/api_config.dart';

class AuthCubit extends Cubit<app_auth.AuthState> {
  AuthCubit() : super(const app_auth.AuthState()) {
    _setupAuthListener();
  }

  final ApiService _api = ApiService.instance;
  SupabaseClient get _supabase => Supabase.instance.client;

  /// Setup auth state listener
  void _setupAuthListener() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      
      if (session == null) {
        print('AuthCubit: User logged out');
        emit(const app_auth.AuthState(isAuthenticated: false));
      } else {
        print('AuthCubit: Auth state changed, loading profile...');
        _loadUserProfile();
      }
    });
  }

  /// Load user profile from backend
  Future<void> _loadUserProfile() async {
    try {
      final response = await _api.get(ApiConfig.USER_PROFILE);

      if (response['success'] == true && response['user'] != null) {
        final user = app_user.User.fromMap(response['user']);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', user.id);
        
        emit(state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        ));
        print('AuthCubit: Profile loaded for user ${user.id}');
      }
    } catch (e) {
      print('AuthCubit: Error loading profile: $e');
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  /// Check if user is already logged in
  Future<void> checkAuthStatus() async {
    emit(state.copyWith(isLoading: true));
    print('AuthCubit: checkAuthStatus started');

    try {
      // Check for existing session
      final session = _supabase.auth.currentSession;
      
      if (session != null) {
        print('AuthCubit: Active session found, loading profile...');
        await _loadUserProfile();
        return;
      }

      // Try to recover session from storage
      print('AuthCubit: No active session, checking storage...');
      
      // Wait for Supabase to restore session from storage
      await Future.delayed(const Duration(milliseconds: 300));
      
      final restoredSession = _supabase.auth.currentSession;
      if (restoredSession != null) {
        print('AuthCubit: Session restored from storage');
        await _loadUserProfile();
        return;
      }
      
      print('AuthCubit: No session found');
      emit(state.copyWith(isLoading: false, isAuthenticated: false));
      
    } catch (e) {
      print('AuthCubit: checkAuthStatus error: $e');
      emit(state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: e.toString(),
      ));
    }
  }

  /// Refresh user data
  Future<void> refreshUserData() async {
    if (state.user == null) return;

    try {
      final response = await _api.get(ApiConfig.USER_PROFILE);

      if (response['success'] == true && response['user'] != null) {
        emit(state.copyWith(
          user: app_user.User.fromMap(response['user']),
          isAuthenticated: true,
        ));
      }
    } catch (e) {
      print('Error refreshing user: $e');
    }
  }

  /// Register new user
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
          error: response['error'] ?? 'Registration failed',
        ));
        return false;
      }

      // Check if email confirmation is required
      if (response['requires_confirmation'] == true) {
        emit(state.copyWith(
          isLoading: false,
          error: response['message'] ?? 'Please check your email to confirm your account',
        ));
        return false;
      }

      // Sign in with Supabase using the credentials
      try {
        final authResponse = await _supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
        
        if (authResponse.session == null) {
          throw Exception('Failed to create session');
        }
        
        print('AuthCubit: Supabase session created successfully');
      } catch (e) {
        print('AuthCubit: Supabase sign in error: $e');
        emit(state.copyWith(
          isLoading: false,
          error: 'Registration succeeded but sign in failed. Please try logging in.',
        ));
        return false;
      }

      // Load user data
      final user = app_user.User.fromMap(response['user']);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', user.id);

      emit(state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      ));
      
      print('AuthCubit: Registration successful');
      return true;
      
    } catch (e) {
      print('AuthCubit: Registration error: $e');
      emit(state.copyWith(
        isLoading: false,
        error: _formatError(e.toString()),
      ));
      return false;
    }
  }

  /// Login user (email OR username)
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
          error: _formatError(response['error'] ?? 'Invalid credentials'),
        ));
        return false;
      }

      // Get the email from response to sign in with Supabase
      final userEmail = response['user']['email'] as String;
      
      try {
        final authResponse = await _supabase.auth.signInWithPassword(
          email: userEmail,
          password: password,
        );
        
        if (authResponse.session == null) {
          throw Exception('Failed to create session');
        }
        
        print('AuthCubit: Session created successfully');
      } catch (e) {
        print('AuthCubit: Supabase sign in error: $e');
        emit(state.copyWith(
          isLoading: false,
          error: 'Login failed. Please try again.',
        ));
        return false;
      }

      // Load user data
      final user = app_user.User.fromMap(response['user']);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', user.id);

      emit(state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      ));
      
      print('AuthCubit: Login successful');
      return true;
      
    } catch (e) {
      print('AuthCubit: Login error: $e');
      emit(state.copyWith(
        isLoading: false,
        error: _formatError(e.toString()),
      ));
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      
      emit(const app_auth.AuthState());
      print('AuthCubit: Logout successful');
    } catch (e) {
      print('AuthCubit: Logout error: $e');
    }
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(error: null));
  }

  /// Update user first name
  Future<void> updateUserFirstName(String newFirstName) async {
    if (state.user == null) return;

    try {
      await _api.put(ApiConfig.USER_UPDATE, {
        'firstName': newFirstName,
      });

      await refreshUserData();
    } catch (e) {
      print('Error updating first name: $e');
      rethrow;
    }
  }

  /// Update user last name
  Future<void> updateUserLastName(String newLastName) async {
    if (state.user == null) return;

    try {
      await _api.put(ApiConfig.USER_UPDATE, {
        'lastName': newLastName,
      });

      await refreshUserData();
    } catch (e) {
      print('Error updating last name: $e');
      rethrow;
    }
  }

  /// Update username
  Future<void> updateUsername(String newUsername) async {
    if (state.user == null) return;

    try {
      await _api.put(ApiConfig.USER_UPDATE, {
        'username': newUsername,
      });

      await refreshUserData();
    } catch (e) {
      print('Error updating username: $e');
      rethrow;
    }
  }

  /// Update user email
  Future<void> updateUserEmail(String newEmail) async {
    if (state.user == null) return;

    try {
      await _api.put(ApiConfig.USER_UPDATE, {
        'email': newEmail,
      });

      await refreshUserData();
    } catch (e) {
      print('Error updating email: $e');
      rethrow;
    }
  }

  /// Format error message
  String _formatError(String error) {
    if (error.contains('already registered')) {
      return 'Email already exists';
    }
    if (error.contains('Invalid login') || error.contains('Invalid credentials')) {
      return 'Invalid username/email or password';
    }
    if (error.contains('already taken') || error.contains('already exists')) {
      return 'Username already taken';
    }
    if (error.contains('confirm your email')) {
      return 'Please confirm your email first';
    }
    if (error.contains('not found')) {
      return 'Account not found';
    }
    return error;
  }
}