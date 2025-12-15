
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
  final List<Offset> _dotPositions = [];
  final List<Offset> _temporaryLine = [];

  @override
  void initState() {
    super.initState();
    _calculateDotPositions();
  }

  void _calculateDotPositions() {
    _dotPositions.clear();
    const double dotSpacing = 70.0;
    const double startX = 30.0; // Centered in 300x300 container
    const double startY = 30.0;
    
    // Create 3x3 grid
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        _dotPositions.add(Offset(
          startX + col * dotSpacing,
          startY + row * dotSpacing,
        ));
      }
    }
  }

  int _getNearestDotIndex(Offset position) {
    for (int i = 0; i < _dotPositions.length; i++) {
      final distance = (position - _dotPositions[i]).distance;
      if (distance < 25) { // Touch radius
        return i;
      }
    }
    return -1;
  }

  void _onPanStart(DragStartDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    
    // Check if starting on a dot
    final nearestDot = _getNearestDotIndex(localPosition);
    if (nearestDot != -1 && !widget.points.contains(nearestDot)) {
      final newPoints = List<int>.from(widget.points)..add(nearestDot);
      widget.onPatternDraw(newPoints);
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);
    
    // Check if we're near a new dot
    final nearestDot = _getNearestDotIndex(localPosition);
    if (nearestDot != -1 && !widget.points.contains(nearestDot)) {
      final newPoints = List<int>.from(widget.points)..add(nearestDot);
      widget.onPatternDraw(newPoints);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    // Nothing needed here for clean pattern
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: CustomPaint(
        size: const Size(240, 240), // Slightly larger than dot area for touch
        painter: _PatternPainter(
          dotPositions: _dotPositions,
          selectedPoints: widget.points,
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  final List<Offset> dotPositions;
  final List<int> selectedPoints;

  _PatternPainter({
    required this.dotPositions,
    required this.selectedPoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Paint for connecting lines
    final linePaint = Paint()
      ..color = AppColors.accentPink
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Paint for unselected dots
    final dotPaint = Paint()
      ..color = AppColors.textSecondary.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // Paint for selected dots
    final selectedDotPaint = Paint()
      ..color = AppColors.accentPink
      ..style = PaintingStyle.fill;

    // Paint for selected dot inner circle
    final innerDotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // 1. Draw lines between selected dots
    for (int i = 0; i < selectedPoints.length - 1; i++) {
      final start = dotPositions[selectedPoints[i]];
      final end = dotPositions[selectedPoints[i + 1]];
      canvas.drawLine(start, end, linePaint);
    }

    // 2. Draw all dots
    for (int i = 0; i < dotPositions.length; i++) {
      final position = dotPositions[i];
      final isSelected = selectedPoints.contains(i);
      
      // Draw outer circle
      canvas.drawCircle(
        position,
        isSelected ? 18 : 14,
        isSelected ? selectedDotPaint : dotPaint,
      );
      
      // Draw inner circle for selected dots
      if (isSelected) {
        canvas.drawCircle(position, 8, innerDotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_PatternPainter oldDelegate) {
    return oldDelegate.selectedPoints != selectedPoints;
  }
}
