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

  /// Refresh user data from database (for profile screen)
  Future<void> refreshUserData() async {
    if (state.user == null) return;
    
    try {
      final userMap = await DBHelper.getUserById(state.user!.id);
      if (userMap != null) {
        final updatedUser = User.fromMap(userMap);
        emit(state.copyWith(
          user: updatedUser,
          isAuthenticated: true,
        ));
      }
    } catch (e) {
      print('Error refreshing user data: $e');
    }
  }

  /// Sign up a new user
  Future<bool> signUp(String name, String email, String password) async {
    emit(state.copyWith(isLoading: true));
    
    try {
      // Check if user already exists by email or username
      final existsEmail = await DBHelper.userExists(email);
      if (existsEmail) {
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

  /// Login existing user (email or username)
  Future<bool> login(String emailOrUsername, String password) async {
    emit(state.copyWith(isLoading: true));
    
    try {
      // Detect if input is email or username
      final isEmail = emailOrUsername.contains('@');
      final userMap = isEmail
          ? await DBHelper.loginUserByEmail(emailOrUsername, password)
          : await DBHelper.loginUserByUsername(emailOrUsername, password);
      
      if (userMap == null) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Invalid credentials',
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

  /// Update user name
  Future<void> updateUserName(String newName) async {
    if (state.user == null) return;
    
    try {
      // Update in database
      await DBHelper.updateUserName(state.user!.id, newName);
      
      // Refresh user data to get updated info
      await refreshUserData();
      
      // Update shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', newName);
    } catch (e) {
      print('Error updating user name: $e');
    }
  }

  /// Update user email
  Future<void> updateUserEmail(String newEmail) async {
    if (state.user == null) return;
    
    try {
      // Check if email already exists
      final exists = await DBHelper.userExists(newEmail);
      if (exists && newEmail != state.user!.email) {
        throw Exception('Email already in use');
      }
      
      // Update in database
      await DBHelper.updateUserEmail(state.user!.id, newEmail);
      
      // Refresh user data to get updated info
      await refreshUserData();
      
      // Update shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userEmail', newEmail);
    } catch (e) {
      print('Error updating user email: $e');
      rethrow;
    }
  }
}