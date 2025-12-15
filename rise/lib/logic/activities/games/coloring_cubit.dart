// lib/logic/coloring/coloring_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'coloring_state.dart';

class ColoringCubit extends Cubit<ColoringState> {
  ColoringCubit() : super(const ColoringState());

  // redo stack – UI doesn't need to know it
  final List<ColoringFillAction> _redo = [];

  void selectTemplate(int index) {
    emit(state.copyWith(template: index));
  }

  void selectColor(Color color) {
    emit(state.copyWith(currentColor: color));
  }

  void replacePaletteColor(int index, Color color) {
    final newPalette = [...state.palette];
    newPalette[index] = color;
    emit(
      state.copyWith(
        palette: newPalette,
        currentColor: color,
      ),
    );
  }

  void addNewColor(Color color) {
    final newPalette = [...state.palette];
    if (newPalette.isNotEmpty) {
      newPalette[newPalette.length - 1] = color;
    }
    emit(
      state.copyWith(
        palette: newPalette,
        currentColor: color,
      ),
    );
  }

  void onFill(int regionIndex, Color previous, Color next) {
    // Add a fill action for current template
    _redo.clear();
    final action = ColoringFillAction(
      template: state.template,
      regionIndex: regionIndex,
      previous: previous,
      next: next,
    );
    final newHistory = [...state.history, action];
    emit(state.copyWith(history: newHistory));
  }

  void undo() {
    if (state.history.isEmpty) return;
    final history = [...state.history];
    final last = history.removeLast();
    _redo.add(last);
    emit(state.copyWith(history: history));
  }

  void redo() {
    if (_redo.isEmpty) return;
    final action = _redo.removeLast();
    final history = [...state.history, action];
    emit(state.copyWith(history: history));
  }

  void clearCurrentTemplate() {
    final filtered = state.history
        .where((a) => a.template != state.template)
        .toList();
    _redo.clear();
    emit(state.copyWith(history: filtered));
  }
}
