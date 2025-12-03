// lib/logic/breathing/breathing_cubit.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'breathing_state.dart';

class BreathingCubit extends Cubit<BreathingState> {
  static const Duration sessionDuration = Duration(minutes: 1);
  Timer? _timer;

  BreathingCubit() : super(const BreathingState());

  void startSession() {
    if (state.running) return;

    _timer?.cancel();
    emit(const BreathingState(
      remaining: sessionDuration,
      running: true,
    ));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newRemaining = state.remaining - const Duration(seconds: 1);

      if (newRemaining.inSeconds <= 0) {
        emit(const BreathingState(
          remaining: Duration.zero,
          running: false,
        ));
        _timer?.cancel();
      } else {
        emit(state.copyWith(
          remaining: newRemaining,
          running: true,
        ));
      }
    });
  }

  void stopSession({bool resetToZero = true}) {
    _timer?.cancel();
    emit(BreathingState(
      remaining: resetToZero ? Duration.zero : state.remaining,
      running: false,
    ));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
