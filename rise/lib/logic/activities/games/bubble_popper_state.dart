// lib/logic/bubble_popper/bubble_popper_state.dart

class BubblePopperState {
  final List<List<bool>> popped;

  const BubblePopperState({
    required this.popped,
  });

  factory BubblePopperState.initial(int rows, int cols) {
    return BubblePopperState(
      popped: List.generate(
        rows,
        (_) => List.generate(cols, (_) => false),
      ),
    );
  }

  BubblePopperState copyWith({
    List<List<bool>>? popped,
  }) {
    return BubblePopperState(
      popped: popped ?? this.popped,
    );
  }
}
