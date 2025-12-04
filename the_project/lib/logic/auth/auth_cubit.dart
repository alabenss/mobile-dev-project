import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_state.dart';
import '../../database/db_helper.dart';
import '../../models/user_model.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState());

  /// Check if user is already logged in
  Future<void> checkAuthStatus() async {
    emit(state.copyWith(isLoading: true));
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      
      if (userId != null) {
        final userMap = await DBHelper.getUserById(userId);
        if (userMap != null) {
          final user = User.fromMap(userMap);
          emit(state.copyWith(
            user: user,
            isAuthenticated: true,
            isLoading: false,
          ));
          return;
        }
      }
      
      emit(state.copyWith(isLoading: false, isAuthenticated: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  /// Sign up a new user
  Future<bool> signUp(String name, String email, String password) async {
    emit(state.copyWith(isLoading: true));
    
    try {
      // Check if user already exists
      final exists = await DBHelper.userExists(email);
      if (exists) {
        emit(state.copyWith(
          isLoading: false,
          error: 'An account with this email already exists',
        ));
        return false;
      }

      // Create new user
      final userId = await DBHelper.createUser(name, email, password);
      
      // Save user ID to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', userId);
      
      // Get the created user
      final userMap = await DBHelper.getUserById(userId);
      if (userMap != null) {
        final user = User.fromMap(userMap);
        emit(state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        ));
        return true;
      }
      
      emit(state.copyWith(isLoading: false, error: 'Failed to create user'));
      return false;
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
      return false;
    }
  }

  /// Login existing user
  Future<bool> login(String email, String password) async {
    emit(state.copyWith(isLoading: true));
    
    try {
      final userMap = await DBHelper.loginUser(email, password);
      
      if (userMap == null) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Invalid email or password',
        ));
        return false;
      }

      // Save user ID to preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', userMap['id'] as int);
      
      final user = User.fromMap(userMap);
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

  /// Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    emit(const AuthState());
  }

  /// Clear error message
  void clearError() {
    emit(state.copyWith(error: null));
  }
}