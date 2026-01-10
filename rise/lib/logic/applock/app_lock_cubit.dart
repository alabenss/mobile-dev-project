import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLockState extends Equatable {
  final bool isLoading;
  final String? lockType;   // 'pin' | 'pattern' | 'password'
  final String? lockValue;  // stored locally
  final bool saveSuccess;
  final bool removeSuccess;
  final bool isAuthenticated;
  final bool wrongAttempt;

  // ✅ NEW: when true, do NOT force lock screen (used for AppLock settings page)
  final bool bypassLock;

  const AppLockState({
    this.isLoading = false,
    this.lockType,
    this.lockValue,
    this.saveSuccess = false,
    this.removeSuccess = false,
    this.isAuthenticated = false,
    this.wrongAttempt = false,
    this.bypassLock = false,
  });

  // ✅ Sentinel to differentiate "not passed" from "passed null"
  static const Object _unset = Object();

  AppLockState copyWith({
    bool? isLoading,
    Object? lockType = _unset,
    Object? lockValue = _unset,
    bool? saveSuccess,
    bool? removeSuccess,
    bool? isAuthenticated,
    bool? wrongAttempt,
    bool? bypassLock,
  }) {
    return AppLockState(
      isLoading: isLoading ?? this.isLoading,
      lockType: lockType == _unset ? this.lockType : lockType as String?,
      lockValue: lockValue == _unset ? this.lockValue : lockValue as String?,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      removeSuccess: removeSuccess ?? this.removeSuccess,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      wrongAttempt: wrongAttempt ?? this.wrongAttempt,
      bypassLock: bypassLock ?? this.bypassLock,
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
        bypassLock,
      ];
}

class AppLockCubit extends Cubit<AppLockState> {
  AppLockCubit() : super(const AppLockState());

  static const String _kLockType = 'app_lock_type';
  static const String _kLockValue = 'app_lock_value';

  // ✅ NEW: allow AppLock settings page to open without asking code
  void setBypassLock(bool value) {
    emit(state.copyWith(bypassLock: value));
  }

  /// Load lock locally
  Future<void> loadLock() async {
    emit(state.copyWith(
      isLoading: true,
      saveSuccess: false,
      removeSuccess: false,
      wrongAttempt: false,
    ));

    try {
      final prefs = await SharedPreferences.getInstance();
      final type = prefs.getString(_kLockType);
      final value = prefs.getString(_kLockValue);

      // If missing anything -> treat as no lock
      if (type == null || value == null || type.isEmpty || value.isEmpty) {
        emit(state.copyWith(
          isLoading: false,
          lockType: null,
          lockValue: null,
          isAuthenticated: true, // no lock => allow access
        ));
        return;
      }

      emit(state.copyWith(
        isLoading: false,
        lockType: type,
        lockValue: value,
        isAuthenticated: false, // lock exists => require verify
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, isAuthenticated: true));
    }
  }

  /// Save lock locally
  Future<void> saveLock(String lockType, String lockValue) async {
    emit(state.copyWith(isLoading: true, saveSuccess: false, wrongAttempt: false));

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLockType, lockType);
      await prefs.setString(_kLockValue, lockValue);

      emit(state.copyWith(
        isLoading: false,
        lockType: lockType,
        lockValue: lockValue,
        saveSuccess: true,
        isAuthenticated: true,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, saveSuccess: false));
    }
  }

  /// Remove lock locally
  Future<void> removeLock() async {
    emit(state.copyWith(isLoading: true, removeSuccess: false, wrongAttempt: false));

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kLockType);
      await prefs.remove(_kLockValue);

      emit(state.copyWith(
        isLoading: false,
        lockType: null,
        lockValue: null,
        removeSuccess: true,
        isAuthenticated: true,
      ));
    } catch (e) {
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

  void clearTransientFlags() {
    emit(state.copyWith(
      saveSuccess: false,
      removeSuccess: false,
      wrongAttempt: false,
    ));
  }

  void resetAuthentication() {
    emit(state.copyWith(
      isAuthenticated: false,
      wrongAttempt: false,
    ));
  }
}
