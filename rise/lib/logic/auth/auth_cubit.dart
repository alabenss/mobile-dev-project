import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_state.dart';
import '../../models/user_model.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState());

  final ApiService _api = ApiService.instance;
  String _mapErrorToMessage(Object e) {
  final error = e.toString().toLowerCase();

  // 🔐 Auth
  if (error.contains('401') || error.contains('invalid credentials')) {
    return 'Invalid credentials. Please check your username and password and try again.';
  }

  // 🧾 Already exists (SIGN UP)
  if (error.contains('email') && error.contains('exist')) {
    return 'This email is already registered. Please use another email.';
  }
  if (error.contains('username') && error.contains('exist')) {
    return 'This username is already taken. Please choose another one.';
  }

  // 🌐 Network / DNS
  if (error.contains('sockete') ||
      error.contains('failed host lookup') ||
      error.contains('no address associated with hostname')) {
    return 'Unable to connect to the server. Please check your internet connection and try again.';
  }

  // ⏱ Timeout
  if (error.contains('timeout')) {
    return 'The request took too long. Please try again later.';
  }

  // 🔌 Server
  if (error.contains('500') || error.contains('server')) {
    return 'Server error. Please try again later.';
  }

  // ❓ Fallback
  return 'Something went wrong. Please try again.';
}



  /// Check if user is already logged in
  Future<void> checkAuthStatus() async {
    emit(state.copyWith(isLoading: true));
    print('AuthCubit: checkAuthStatus started');

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      print('AuthCubit: stored userId = $userId');

      if (userId == null) {
        print('AuthCubit: no userId -> show login');
        emit(state.copyWith(isLoading: false, isAuthenticated: false));
        return;
      }

      print('AuthCubit: calling USER_PROFILE ${ApiConfig.BASE_URL}${ApiConfig.USER_PROFILE}');

      final response = await _api
          .get(
            ApiConfig.USER_PROFILE,
            params: {'userId': userId.toString()},
          )
          .timeout(const Duration(seconds: 8));

      print('AuthCubit: USER_PROFILE response = $response');

      if (response['success'] == true && response['user'] != null) {
        final user = User.fromMap(response['user']);
        emit(state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        ));
        print('AuthCubit: authenticated as ${user.id}');
      } else {
        print('AuthCubit: profile invalid -> logout local userId');
        await prefs.remove('userId');
        emit(state.copyWith(isLoading: false, isAuthenticated: false));
      }
    } catch (e) {
    
      print('AuthCubit: checkAuthStatus error: $e');

      // ✅ critical: don't stay stuck loading forever
      emit(state.copyWith(isLoading: false, isAuthenticated: false, error: _mapErrorToMessage(e)));
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
  emit(state.copyWith(error: _mapErrorToMessage(e)));
}

  }

  /// Register
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
  emit(state.copyWith(
    isLoading: false,
    error: _mapErrorToMessage(e),
  ));
  return false;
}

  }

  /// Login (email OR username)
  Future<bool> login(String identifier, String password) async {
    emit(state.copyWith(isLoading: true));

    try {
      final response = await _api.post(ApiConfig.AUTH_LOGIN, {
        'email': identifier, // can be email or username
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
    }catch (e) {
  emit(state.copyWith(
    isLoading: false,
    error: _mapErrorToMessage(e),
  ));
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

  /// Update user first name
  Future<void> updateUserFirstName(String newFirstName) async {
    if (state.user == null) return;

    try {
      await _api.put(ApiConfig.USER_UPDATE, {
        'userId': state.user!.id,
        'firstName': newFirstName,
      });

      await refreshUserData();
    } catch (e) {
  emit(state.copyWith(error: _mapErrorToMessage(e)));
}

  }

  /// Update user last name
  Future<void> updateUserLastName(String newLastName) async {
    if (state.user == null) return;

    try {
      await _api.put(ApiConfig.USER_UPDATE, {
        'userId': state.user!.id,
        'lastName': newLastName,
      });

      await refreshUserData();
    } catch (e) {
  emit(state.copyWith(error: _mapErrorToMessage(e)));
}

  }

  /// Update username
  Future<void> updateUsername(String newUsername) async {
    if (state.user == null) return;

    try {
      await _api.put(ApiConfig.USER_UPDATE, {
        'userId': state.user!.id,
        'username': newUsername,
      });

      await refreshUserData();
    }catch (e) {
  emit(state.copyWith(error: _mapErrorToMessage(e)));
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
  emit(state.copyWith(error: _mapErrorToMessage(e)));
}

  }
}
