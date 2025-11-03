import 'package:flutter/material.dart';
import 'package:the_project/views/themes/style_simple/colors.dart';

class PatternLockWidget extends StatefulWidget {
  final List<int> points;
  final Function(List<int>) onPatternDraw;

  const PatternLockWidget({
    super.key,
    required this.points,
    required this.onPatternDraw,
  });

  @override
  State<PatternLockWidget> createState() => _PatternLockWidgetState();
}

class _PatternLockWidgetState extends State<PatternLockWidget> {
  List<Offset> dotPositions = [];

  @override
  void initState() {
    super.initState();
    _calculateDotPositions();
  }

  void _calculateDotPositions() {
    dotPositions.clear();
    const double spacing = 70.0;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        dotPositions.add(Offset(j * spacing, i * spacing));
      }
    }
  }

  int _getNearestDot(Offset position) {
    for (int i = 0; i < dotPositions.length; i++) {
      if ((position - dotPositions[i]).distance < 30) {
        return i;
      }
    }
    return -1;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    int nearestDot = _getNearestDot(localPosition);
    if (nearestDot != -1 && !widget.points.contains(nearestDot)) {
      List<int> newPoints = List.from(widget.points)..add(nearestDot);
      widget.onPatternDraw(newPoints);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    // Pattern drawing completed
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Container(
        width: 210,
        height: 210,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: CustomPaint(
          painter: PatternPainter(
            points: widget.points,
            dotPositions: dotPositions,
          ),
        ),
      ),
    );
  }
}

class PatternPainter extends CustomPainter {
  final List<int> points;
  final List<Offset> dotPositions;

  PatternPainter({required this.points, required this.dotPositions});

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = AppColors.textSecondary
      ..style = PaintingStyle.fill;

    final selectedDotPaint = Paint()
      ..color = AppColors.accentPink
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = AppColors.accentPink
      ..strokeWidth = 3.0
      ..style= PaintingStyle.stroke;

    // Draw lines between selected points
    if (points.length > 1) {
      for (int i = 0; i < points.length - 1; i++) {
        canvas.drawLine(
          dotPositions[points[i]],
          dotPositions[points[i + 1]],
          linePaint,
        );
      }
    }

    // Draw dots
    for (int i = 0; i < dotPositions.length; i++) {
      canvas.drawCircle(
        dotPositions[i],
        points.contains(i) ? 12 : 8,
        points.contains(i) ? selectedDotPaint : dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}