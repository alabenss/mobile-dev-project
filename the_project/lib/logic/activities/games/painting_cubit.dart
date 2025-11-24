// lib/logic/painting/painting_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'painting_state.dart';

class PaintingCubit extends Cubit<PaintingState> {
  PaintingCubit() : super(const PaintingState());

  // Background color used by eraser (must match canvas bg in UI)
  static const Color canvasBg = Color(0xFFF5EAE5);

  // redo stack (not needed in state for UI)
  final List<PaintingStroke> _redo = [];

  void startStroke(Offset pos) {
    _redo.clear();

    final strokeColor = state.eraser ? canvasBg : state.color;
    final newStroke = PaintingStroke(
      points: [PaintingPoint(pos, state.width)],
      color: strokeColor,
      width: state.width,
    );

    final strokes = [...state.strokes, newStroke];
    emit(state.copyWith(strokes: strokes));
  }

  void extendStroke(Offset pos) {
    if (state.strokes.isEmpty) return;

    final strokes = [...state.strokes];
    final last = strokes.last;

    final updatedLast = last.copyWith(
      points: [...last.points, PaintingPoint(pos, state.width)],
    );

    strokes[strokes.length - 1] = updatedLast;
    emit(state.copyWith(strokes: strokes));
  }

  void undo() {
    if (state.strokes.isEmpty) return;
    final strokes = [...state.strokes];
    final last = strokes.removeLast();
    _redo.add(last);
    emit(state.copyWith(strokes: strokes));
  }

  void redo() {
    if (_redo.isEmpty) return;
    final stroke = _redo.removeLast();
    final strokes = [...state.strokes, stroke];
    emit(state.copyWith(strokes: strokes));
  }

  void clear() {
    _redo.clear();
    emit(state.copyWith(strokes: []));
  }

  void setWidth(double w) {
    emit(state.copyWith(width: w, eraser: state.eraser));
  }

  void toggleEraser() {
    emit(state.copyWith(eraser: !state.eraser));
  }

  void setColor(Color color) {
    emit(state.copyWith(color: color, eraser: false));
  }
}
