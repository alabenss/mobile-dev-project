import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_service.dart';
import '../../config/api_config.dart';

class AppLockState extends Equatable {
  final bool isLoading;
  final String? lockType;
  final String? lockValue;
  final bool saveSuccess;
  final bool removeSuccess;
  final bool isAuthenticated;
  final bool wrongAttempt;

  const AppLockState({
    this.isLoading = false,
    this.lockType,
    this.lockValue,
    this.saveSuccess = false,
    this.removeSuccess = false,
    this.isAuthenticated = false,
    this.wrongAttempt = false,
  });

  AppLockState copyWith({
    bool? isLoading,
    String? lockType,
    String? lockValue,
    bool? saveSuccess,
    bool? removeSuccess,
    bool? isAuthenticated,
    bool? wrongAttempt,
  }) {
    return AppLockState(
      isLoading: isLoading ?? this.isLoading,
      lockType: lockType ?? this.lockType,
      lockValue: lockValue ?? this.lockValue,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      removeSuccess: removeSuccess ?? this.removeSuccess,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      wrongAttempt: wrongAttempt ?? this.wrongAttempt,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        lockType,
        lockValue,
        saveSuccess,
        removeSuccess,
        isAuthenticated,
        wrongAttempt,
      ];
}

class AppLockCubit extends Cubit<AppLockState> {
  AppLockCubit() : super(const AppLockState());

  final ApiService _api = ApiService.instance;

  /// Get logged-in userId from SharedPreferences
  Future<int?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  /// Load app lock
  Future<void> loadLock() async {
    emit(state.copyWith(isLoading: true));

    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        emit(state.copyWith(isLoading: false));
        return;
      }

      final response = await _api.get(
        ApiConfig.APP_LOCK_GET,
        params: {'userId': userId.toString()},
      );

      if (response['success'] == true && response['lock'] != null) {
        emit(state.copyWith(
          isLoading: false,
          lockType: response['lock']['lockType'],
          lockValue: response['lock']['lockValue'],
          isAuthenticated: false,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          lockType: null,
          lockValue: null,
          isAuthenticated: false,
        ));
      }
    } catch (e) {
      print('AppLockCubit: Error loading lock: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Save app lock
  Future<void> saveLock(String lockType, String lockValue) async {
    emit(state.copyWith(isLoading: true, saveSuccess: false));

    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        emit(state.copyWith(isLoading: false));
        return;
      }

      await _api.post(ApiConfig.APP_LOCK_SAVE, {
        'userId': userId,
        'lockType': lockType,
        'lockValue': lockValue,
      });

      emit(state.copyWith(
        isLoading: false,
        lockType: lockType,
        lockValue: lockValue,
        saveSuccess: true,
        isAuthenticated: true,
      ));
    } catch (e) {
      print('AppLockCubit: Error saving lock: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Remove app lock
  Future<void> removeLock() async {
    emit(state.copyWith(isLoading: true, removeSuccess: false));

    try {
      final userId = await _getCurrentUserId();
      if (userId == null) {
        emit(state.copyWith(isLoading: false));
        return;
      }

      // FIXED: Pass userId as query parameter, not as data
      await _api.delete(
        ApiConfig.APP_LOCK_REMOVE,
        params: {'userId': userId.toString()},
      );

      emit(state.copyWith(
        isLoading: false,
        lockType: null,
        lockValue: null,
        removeSuccess: true,
        isAuthenticated: true,
      ));
    } catch (e) {
      print('AppLockCubit: Error removing lock: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Verify lock input
  Future<void> verifyLock(String input) async {
    if (state.lockType == null || state.lockValue == null) {
      emit(state.copyWith(isAuthenticated: true, wrongAttempt: false));
      return;
    }

    final isCorrect = input == state.lockValue;
    emit(state.copyWith(
      isAuthenticated: isCorrect,
      wrongAttempt: !isCorrect,
    ));
  }

  /// Clear one-shot flags
  void clearTransientFlags() {
    emit(state.copyWith(
      saveSuccess: false,
      removeSuccess: false,
      wrongAttempt: false,
    ));
  }

  /// Reset authentication (app background / logout)
  void resetAuthentication() {
    emit(state.copyWith(
      isAuthenticated: false,
      wrongAttempt: false,
    ));
  }
}