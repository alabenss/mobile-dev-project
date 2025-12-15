// lib/logic/breathing/breathing_state.dart

class BreathingState {
  final Duration remaining;
  final bool running;

  const BreathingState({
    this.remaining = const Duration(minutes: 1),
    this.running = false,
  });

  BreathingState copyWith({
    Duration? remaining,
    bool? running,
  }) {
    return BreathingState(
      remaining: remaining ?? this.remaining,
      running: running ?? this.running,
    );
  }
}
