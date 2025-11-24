// lib/logic/puzzle/puzzle_cubit.dart
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'puzzle_state.dart';

class PuzzleCubit extends Cubit<PuzzleState> {
  final int n;

  PuzzleCubit({this.n = 3})
      : super(PuzzleState(tiles: List<int>.generate(
          n * n,
          (i) => (i + 1) % (n * n),
        ))) {
    reset(shuffle: true);
  }

  void reset({bool shuffle = false}) {
    // initial solved state [1..8,0]
    var tiles = List<int>.generate(n * n, (i) => (i + 1) % (n * n));
    bool showBanner = false;

    if (shuffle) {
      tiles = _shuffleToSolvable(tiles);
    } else {
      showBanner = false;
    }

    emit(PuzzleState(
      tiles: tiles,
      showSolvedBanner: showBanner,
    ));
  }

  List<int> _shuffleToSolvable(List<int> tiles) {
    final rand = Random();
    final list = List<int>.from(tiles);

    do {
      list.shuffle(rand);
    } while (!_isSolvable(list) || _isSolved(list));

    return list;
  }

  bool _isSolvable(List<int> list) {
    // For odd grids (3x3), solvable when inversion count is even
    int inv = 0;
    final nums = list.where((x) => x != 0).toList();
    for (int i = 0; i < nums.length; i++) {
      for (int j = i + 1; j < nums.length; j++) {
        if (nums[i] > nums[j]) inv++;
      }
    }
    return inv.isEven;
  }

  bool _isSolved(List<int> tiles) {
    for (int i = 0; i < tiles.length - 1; i++) {
      if (tiles[i] != i + 1) return false;
    }
    return tiles.last == 0;
  }

  void onTileTap(int idx) {
    final tiles = List<int>.from(state.tiles);
    final empty = tiles.indexOf(0);
    final canSwap = _isNeighbor(idx, empty);
    if (!canSwap) return;

    final t = tiles[idx];
    tiles[idx] = 0;
    tiles[empty] = t;

    final solved = _isSolved(tiles);

    emit(state.copyWith(
      tiles: tiles,
      showSolvedBanner: solved,
    ));
  }

  bool _isNeighbor(int a, int b) {
    final ax = a ~/ n, ay = a % n;
    final bx = b ~/ n, by = b % n;
    return (ax == bx && (ay - by).abs() == 1) ||
        (ay == by && (ax - bx).abs() == 1);
  }
}
