// lib/logic/bubble_popper/bubble_popper_cubit.dart
import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bubble_popper_state.dart';

class BubblePopperCubit extends Cubit<BubblePopperState> {
  final int rows;
  final int cols;
  late final AudioPlayer _player;

  BubblePopperCubit({this.rows = 7, this.cols = 4})
      : super(BubblePopperState.initial(rows, cols)) {
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    _player = AudioPlayer(playerId: 'pop');
    await _player.setReleaseMode(ReleaseMode.stop);
    await _player.setVolume(1.0);
    await _player.setSourceAsset('sounds/pop.mp3'); // ensure in pubspec.yaml
  }

  Future<void> _playPop() async {
    try {
      await _player.seek(Duration.zero);
      await _player.resume();
    } catch (_) {
      // ignore device-specific audio errors
    }
  }

  void toggle(int r, int c) {
    // Deep copy grid
    final newGrid = [
      for (final row in state.popped) [...row],
    ];
    newGrid[r][c] = !newGrid[r][c];

    emit(state.copyWith(popped: newGrid));

    HapticFeedback.lightImpact();
    _playPop();
  }

  @override
  Future<void> close() async {
    try {
      await _player.dispose();
    } catch (_) {}
    return super.close();
  }
}
