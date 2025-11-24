// lib/logic/puzzle/puzzle_state.dart

class PuzzleState {
  final List<int> tiles; // values 1..8 and 0 for empty
  final bool showSolvedBanner;

  const PuzzleState({
    required this.tiles,
    this.showSolvedBanner = false,
  });

  PuzzleState copyWith({
    List<int>? tiles,
    bool? showSolvedBanner,
  }) {
    return PuzzleState(
      tiles: tiles ?? this.tiles,
      showSolvedBanner: showSolvedBanner ?? this.showSolvedBanner,
    );
  }
}
