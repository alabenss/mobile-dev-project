// lib/logic/coloring/coloring_state.dart
import 'package:flutter/material.dart';

class ColoringFillAction {
  final int template;
  final int regionIndex;
  final Color previous;
  final Color next;

  const ColoringFillAction({
    required this.template,
    required this.regionIndex,
    required this.previous,
    required this.next,
  });
}

class ColoringState {
  final int template; // 0..5
  final Color currentColor;
  final List<Color> palette;
  final List<ColoringFillAction> history;

  const ColoringState({
    this.template = 0,
    this.currentColor = const Color(0xFF3ECF8E),
    this.palette = const [
      Color(0xFF1E3A5F),
      Color(0xFFE53935),
      Color(0xFF3ECF8E),
      Color(0xFFFFC107),
      Color(0xFF42A5F5),
      Color(0xFFBA68C8),
      Color(0xFFFF7043),
      Color(0xFFFFEB3B),
      Color(0xFF8D6E63),
      Color(0xFFFFFFFF),
    ],
    this.history = const [],
  });

  ColoringState copyWith({
    int? template,
    Color? currentColor,
    List<Color>? palette,
    List<ColoringFillAction>? history,
  }) {
    return ColoringState(
      template: template ?? this.template,
      currentColor: currentColor ?? this.currentColor,
      palette: palette ?? this.palette,
      history: history ?? this.history,
    );
  }
}
