
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:the_project/database/db_helper.dart';

class AppLockState extends Equatable {
  final bool isLoading;
  final String? lockType;      // 'pin', 'pattern', 'password'
  final String? lockValue;     // raw stored string
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
  List<Object?> get props =>
      [isLoading, lockType, lockValue, saveSuccess, removeSuccess, isAuthenticated, wrongAttempt];
}

class AppLockCubit extends Cubit<AppLockState> {
  AppLockCubit() : super(const AppLockState());

  /// Get the current user ID.
  /// TODO: replace with your AuthCubit user id if you have one.
  Future<int> _getCurrentUserId() async {
    return await DBHelper.ensureDefaultUser();
  }

  Future<void> loadLock() async {
    emit(state.copyWith(isLoading: true, saveSuccess: false, removeSuccess: false));
    try {
      final userId = await _getCurrentUserId();
      final data = await DBHelper.getAppLock(userId);
      if (data == null) {
        emit(state.copyWith(
          isLoading: false, 
          lockType: null, 
          lockValue: null,
          isAuthenticated: false,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          lockType: data['lockType'] as String?,
          lockValue: data['lockValue'] as String?,
          isAuthenticated: false, // Start as not authenticated
        ));
      }
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> saveLock(String lockType, String lockValue) async {
    emit(state.copyWith(isLoading: true, saveSuccess: false, removeSuccess: false));
    try {
      final userId = await _getCurrentUserId();
      await DBHelper.saveAppLock(
        userId: userId,
        lockType: lockType,
        lockValue: lockValue,
      );

      emit(state.copyWith(
        isLoading: false,
        lockType: lockType,
        lockValue: lockValue,
        saveSuccess: true,
        isAuthenticated: true, // After setting lock, user is authenticated
      ));
    } catch (_) {
      emit(state.copyWith(isLoading: false, saveSuccess: false));
    }
  }

  Future<void> removeLock() async {
    emit(state.copyWith(isLoading: true, saveSuccess: false, removeSuccess: false));
    try {
      final userId = await _getCurrentUserId();
      await DBHelper.removeAppLock(userId);
      emit(state.copyWith(
        isLoading: false,
        lockType: null,
        lockValue: null,
        removeSuccess: true,
        isAuthenticated: true, // After removing lock, user is authenticated
      ));
    } catch (_) {
      emit(state.copyWith(isLoading: false, removeSuccess: false));
    }
  }

  Future<void> verifyLock(String input) async {
    // No lock? authenticated by default
    if (state.lockType == null || state.lockValue == null) {
      emit(state.copyWith(isAuthenticated: true, wrongAttempt: false));
      return;
    }

    final isCorrect = input == state.lockValue;
    if (isCorrect) {
      emit(state.copyWith(isAuthenticated: true, wrongAttempt: false));
    } else {
      emit(state.copyWith(isAuthenticated: false, wrongAttempt: true));
    }
  }

  /// Call this if you want to clear one-shot flags like saveSuccess, removeSuccess, wrongAttempt
  void clearTransientFlags() {
    emit(state.copyWith(
      saveSuccess: false,
      removeSuccess: false,
      wrongAttempt: false,
    ));
  }

  /// Reset authentication state (for logout or when going to background)
  void resetAuthentication() {
    emit(state.copyWith(
      isAuthenticated: false,
      wrongAttempt: false,
    ));
  }
}
