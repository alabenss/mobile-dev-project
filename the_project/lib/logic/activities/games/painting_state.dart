// lib/logic/painting/painting_state.dart
import 'package:flutter/material.dart';

class PaintingPoint {
  final Offset offset;
  final double width;

  const PaintingPoint(this.offset, this.width);
}

class PaintingStroke {
  final List<PaintingPoint> points;
  final Color color;
  final double width;

  const PaintingStroke({
    required this.points,
    required this.color,
    required this.width,
  });

  PaintingStroke copyWith({
    List<PaintingPoint>? points,
    Color? color,
    double? width,
  }) {
    return PaintingStroke(
      points: points ?? List<PaintingPoint>.from(this.points),
      color: color ?? this.color,
      width: width ?? this.width,
    );
  }
}

class PaintingState {
  final List<PaintingStroke> strokes;
  final Color color;
  final double width;
  final bool eraser;

  const PaintingState({
    this.strokes = const [],
    this.color = const Color(0xFFF7D254),
    this.width = 6,
    this.eraser = false,
  });

  PaintingState copyWith({
    List<PaintingStroke>? strokes,
    Color? color,
    double? width,
    bool? eraser,
  }) {
    return PaintingState(
      strokes: strokes ?? this.strokes,
      color: color ?? this.color,
      width: width ?? this.width,
      eraser: eraser ?? this.eraser,
    );
  }
}
