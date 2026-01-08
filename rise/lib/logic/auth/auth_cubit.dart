import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_state.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState());

  final ApiService _api = ApiService.instance;

  /// Check if user is already logged in
  Future<void> checkAuthStatus() async {
    emit(state.copyWith(isLoading: true));

    try {
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
        final user = User.fromMap(response['user']);
        emit(state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(isLoading: false, isAuthenticated: false));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Refresh user data
  Future<void> refreshUserData() async {
    if (state.user == null) return;

    try {
      final response = await _api.get(
        ApiConfig.USER_PROFILE,
        params: {'userId': state.user!.id.toString()},
      );

      if (response['success'] == true && response['user'] != null) {
        emit(state.copyWith(
          user: User.fromMap(response['user']),
          isAuthenticated: true,
        ));
      }
    } catch (e) {
      print('Error refreshing user: $e');
    }
  }

  /// Register
  Future<bool> signUp(String name, String email, String password) async {
    emit(state.copyWith(isLoading: true));

    try {
      final response = await _api.post(ApiConfig.AUTH_REGISTER, {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response['success'] != true || response['user'] == null) {
        emit(state.copyWith(
          isLoading: false,
          error: response['error'] ?? 'Registration failed',
        ));
        return false;
      }

      final user = User.fromMap(response['user']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', user.id);

      emit(state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      return false;
    }
  }

  /// Login (email OR username)
  Future<bool> login(String identifier, String password) async {
    emit(state.copyWith(isLoading: true));

    try {
      final response = await _api.post(ApiConfig.AUTH_LOGIN, {
        'email': identifier,
        'password': password,
      });

      if (response['success'] != true || response['user'] == null) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Invalid credentials',
        ));
        return false;
      }

      final user = User.fromMap(response['user']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', user.id);

      emit(state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      ));
      return true;
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    emit(const AuthState());
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(error: null));
  }

  /// Update user name
  Future<void> updateUserName(String newName) async {
    if (state.user == null) return;

    try {
      await _api.put(ApiConfig.USER_UPDATE, {
        'userId': state.user!.id,
        'name': newName,
      });

      await refreshUserData();
    } catch (e) {
      print('Error updating name: $e');
    }
  }

  /// Update user email
  Future<void> updateUserEmail(String newEmail) async {
    if (state.user == null) return;

    try {
      await _api.put(ApiConfig.USER_UPDATE, {
        'userId': state.user!.id,
        'email': newEmail,
      });

      await refreshUserData();
    } catch (e) {
      print('Error updating email: $e');
      rethrow;
    }
  }
}
