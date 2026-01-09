import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ✅ CORRECT - Using aliases
import 'auth_state.dart' as app_auth;
import '../../models/user_model.dart' as app_user;

import '../../services/api_service.dart';
import '../../config/api_config.dart';

class AuthCubit extends Cubit<app_auth.AuthState> {
  AuthCubit() : super(const app_auth.AuthState()) {
    // Listen to auth state changes
    _setupAuthListener();
  }

  final ApiService _api = ApiService.instance;
  SupabaseClient get _supabase => Supabase.instance.client;

  /// Setup auth state listener
  void _setupAuthListener() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      
      if (session == null) {
        // User logged out
        print('AuthCubit: User logged out');
        emit(const app_auth.AuthState(isAuthenticated: false));
      } else {
        // User logged in or token refreshed
        print('AuthCubit: Auth state changed');
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
        
        // Save userId to SharedPreferences
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
  /// Check if user is already logged in
/// Check if user is already logged in
Future<void> checkAuthStatus() async {
  emit(state.copyWith(isLoading: true));
  print('AuthCubit: checkAuthStatus started');

  try {
    final session = _supabase.auth.currentSession;
    
    if (session != null) {
      // Session exists, load profile
      print('AuthCubit: Active session found, loading profile...');
      await _loadUserProfile();
      return;
    }

    // 🔥 No current session - try to restore from local storage
    print('AuthCubit: No active session, trying to restore...');
    
    // Supabase automatically restores sessions from local storage
    // Just wait a moment for it to initialize
    await Future.delayed(const Duration(milliseconds: 500));
    
    final restoredSession = _supabase.auth.currentSession;
    if (restoredSession != null) {
      print('AuthCubit: Session restored from storage');
      await _loadUserProfile();
      return;
    }
    
    // No session found at all
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

    // 🔥 Sign in with Supabase to create persistent session
    try {
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (authResponse.session != null) {
        print('AuthCubit: Supabase session created successfully');
      }
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
    
    // Save userId
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
  /// Login user (email OR username)
Future<bool> login(String identifier, String password) async {
  emit(state.copyWith(isLoading: true));

  try {
    final response = await _api.post(ApiConfig.AUTH_LOGIN, {
      'email': identifier, // can be email or username
      'password': password,
    });

    if (response['success'] != true) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Invalid credentials',
      ));
      return false;
    }

    // 🔥 Set the session properly in Supabase
    if (response['session'] != null) {
      final sessionData = response['session'];
      
      try {
        // Use setSession to properly store the session
        await _supabase.auth.setSession(sessionData['access_token']);
        print('AuthCubit: Session set successfully');
      } catch (e) {
        print('AuthCubit: setSession failed: $e');
        
        // Fallback: Store tokens manually
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', sessionData['access_token']);
        if (sessionData['refresh_token'] != null) {
          await prefs.setString('refresh_token', sessionData['refresh_token']);
        }
      }
    }

    // Load user data
    final user = app_user.User.fromMap(response['user']);
    
    // Save userId to SharedPreferences
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
      error: 'Invalid credentials',
    ));
    return false;
  }
}

  /// Logout user
  Future<void> logout() async {
    try {
      // Sign out from Supabase
      await _supabase.auth.signOut();
      
      // Clear local data
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
    if (error.contains('Invalid login')) {
      return 'Invalid credentials';
    }
    if (error.contains('already taken') || error.contains('already exists')) {
      return 'Username already taken';
    }
    if (error.contains('confirm your email')) {
      return 'Please confirm your email first';
    }
    return error;
  }
}
