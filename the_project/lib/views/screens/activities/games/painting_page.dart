import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../../../widgets/activities/activity_shell.dart'; 
import '../../../themes/style_simple/colors.dart';

class PaintingPage extends StatefulWidget {
  const PaintingPage({super.key});

  @override
  State<PaintingPage> createState() => _PaintingPageState();
}

class _PaintingPageState extends State<PaintingPage> {
  final GlobalKey _repaintKey = GlobalKey();

  // Current tool state
  Color _color = const Color(0xFFF7D254); 
  double _width = 6;
  bool _eraser = false;

  // Stacks for undo/redo
  final List<_Stroke> _strokes = [];
  final List<_Stroke> _redo = [];

  // Background color of the drawing card (eraser uses this)
  static const Color _canvasBg = Color(0xFFF5EAE5);

  // Available brush widths for the dock
  static const List<double> _widths = [2, 4, 6, 10, 18];

  void _startStroke(Offset pos) {
    setState(() {
      _redo.clear();
      _strokes.add(
        _Stroke(
          [_Point(pos, _width)],
          color: _eraser ? _canvasBg : _color,
          width: _width,
        ),
      );
    });
  }

  void _extendStroke(Offset pos) {
    setState(() {
      if (_strokes.isEmpty) return;
      _strokes.last.points.add(_Point(pos, _width));
    });
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() => _redo.add(_strokes.removeLast()));
  }

  void _redoAct() {
    if (_redo.isEmpty) return;
    setState(() => _strokes.add(_redo.removeLast()));
  }

  void _clear() {
    setState(() {
      _strokes.clear();
      _redo.clear();
    });
  }

  Future<void> _saveMock() async {
    // Hook ready: the RepaintBoundary is set. Keep it simple for now.
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image Saved!.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ActivityShell(
      title: 'Draw',
      child: Column(
        children: [
          // Prompt
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3EB),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Text(
                'Take a deep breath, pick your color, and let your creativity flow.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.3,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          // Tool row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ToolButton(icon: Icons.undo_rounded, onTap: _undo),
                const SizedBox(width: 14),
                _ToolButton(icon: Icons.redo_rounded, onTap: _redoAct),
                const SizedBox(width: 14),
                _ToolButton(icon: Icons.cleaning_services_rounded, onTap: _clear),
                const SizedBox(width: 14),
                _ToolButton(icon: Icons.download_rounded, onTap: _saveMock),
              ],
            ),
          ),

          // Drawing area (big card)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  color: _canvasBg,
                  child: RepaintBoundary(
                    key: _repaintKey,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return GestureDetector(
                          onPanStart: (d) => _startStroke(d.localPosition),
                          onPanUpdate: (d) => _extendStroke(d.localPosition),
                          child: CustomPaint(
                            painter: _CanvasPainter(_strokes),
                            size: Size(constraints.maxWidth, constraints.maxHeight),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom tool dock (brushes + eraser + color dot)
          _ToolDock(
            selectedWidth: _width,
            onWidth: (w) => setState(() => _width = w),
            eraser: _eraser,
            onToggleEraser: () => setState(() => _eraser = !_eraser),
            color: _color,
            onPickColor: () async {
              final picked = await showModalBottomSheet<Color>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                ),
                builder: (_) => _ColorPickerSheet(initial: _color),
              );
              if (picked != null) {
                setState(() {
                  _color = picked;
                  _eraser = false;
                });
              }
            },
          ),
        ],
      ),
    );
  }
}

class _Point {
  final Offset offset;
  final double width;
  _Point(this.offset, this.width);
}

class _Stroke {
  final List<_Point> points;
  final Color color;
  final double width;
  _Stroke(this.points, {required this.color, required this.width});
}

class _CanvasPainter extends CustomPainter {
  final List<_Stroke> strokes;
  _CanvasPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in strokes) {
      if (s.points.length < 2) {
        final p = Paint()
          ..color = s.color
          ..strokeWidth = s.width
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        if (s.points.isNotEmpty) {
          canvas.drawPoints(
            ui.PointMode.points,
            [s.points.first.offset],
            p..strokeWidth = s.width,
          );
        }
        continue;
      }

      final p = Paint()
        ..color = s.color
        ..strokeWidth = s.width
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path()..moveTo(s.points.first.offset.dx, s.points.first.offset.dy);
      for (int i = 1; i < s.points.length; i++) {
        final prev = s.points[i - 1].offset;
        final curr = s.points[i].offset;
        final mid = Offset((prev.dx + curr.dx) / 2, (prev.dy + curr.dy) / 2);
        path.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
      }
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(covariant _CanvasPainter oldDelegate) =>
      oldDelegate.strokes != strokes;
}

/// -------------------------------------
/// UI bits
/// -------------------------------------

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ToolButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2321),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.15),
              offset: const Offset(0, 3),
              blurRadius: 6,
            )
          ],
        ),
        child: Icon(icon, color: const Color(0xFFE9C7B6)),
      ),
    );
  }
}

class _ToolDock extends StatelessWidget {
  static const List<double> widths = [2, 4, 6, 10, 18];
  
  final double selectedWidth;
  final ValueChanged<double> onWidth;
  final bool eraser;
  final VoidCallback onToggleEraser;
  final Color color;
  final VoidCallback onPickColor;

  const _ToolDock({
    required this.selectedWidth,
    required this.onWidth,
    required this.eraser,
    required this.onToggleEraser,
    required this.color,
    required this.onPickColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.1), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ..._ToolDock.widths.map((w) => _BrushIcon(
                width: w,
                selected: selectedWidth == w && !eraser,
                onTap: () => onWidth(w),
              )),
          _EraserIcon(selected: eraser, onTap: onToggleEraser),
          _ColorDot(color: color, onTap: onPickColor),
        ],
      ),
    );
  }
}

class _BrushIcon extends StatelessWidget {
  final double width;
  final bool selected;
  final VoidCallback onTap;
  const _BrushIcon({required this.width, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.accentPink : Colors.black12,
                width: selected ? 2.2 : 1,
              ),
            ),
            alignment: Alignment.center,
            child: Container(
              width: width.clamp(2, 18),
              height: width.clamp(2, 18),
              decoration: const BoxDecoration(
                color: Colors.black87,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 36,
            height: 3,
            color: Colors.black12,
          ),
        ],
      ),
    );
  }
}

class _EraserIcon extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  const _EraserIcon({required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_fix_off_rounded,
              color: selected ? AppColors.accentPink : Colors.black54),
          const SizedBox(height: 6),
          Container(width: 36, height: 3, color: Colors.black12),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _ColorDot({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 34, height: 34,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(colors: [
                Colors.red, Colors.orange, Colors.yellow, Colors.green,
                Colors.cyan, Colors.blue, Colors.purple, Colors.red
              ]),
            ),
          ),
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(color: Colors.white, width: 3),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple HSV/Opacity picker bottom sheet
class _ColorPickerSheet extends StatefulWidget {
  final Color initial;
  const _ColorPickerSheet({required this.initial});

  @override
  State<_ColorPickerSheet> createState() => _ColorPickerSheetState();
}

class _ColorPickerSheetState extends State<_ColorPickerSheet> {
  late double _h, _s, _v, _a;

  @override
  void initState() {
    super.initState();
    final hsv = HSVColor.fromColor(widget.initial);
    _h = hsv.hue;
    _s = hsv.saturation;
    _v = hsv.value;
    _a = widget.initial.opacity;
  }

  Color get _current => HSVColor.fromAHSV(_a, _h, _s, _v).toColor();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 44, height: 5,
              decoration: BoxDecoration(
                color: Colors.black12, borderRadius: BorderRadius.circular(3))),
          const SizedBox(height: 16),
          const Text('Colors', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 14),

          _sliderRow('Hue', _h, 0, 360, (v)=> setState(()=> _h = v)),
          _sliderRow('Saturation', _s, 0, 1, (v)=> setState(()=> _s = v)),
          _sliderRow('Value', _v, 0, 1, (v)=> setState(()=> _v = v)),
          _sliderRow('Opacity', _a, 0, 1, (v)=> setState(()=> _a = v)),

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: _current, shape: BoxShape.circle,
                  border: Border.all(color: Colors.black12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPink,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => Navigator.pop(context, _current),
              child: const Text('Use Color', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _sliderRow(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        Slider(
          value: value, min: min, max: max, divisions: (max-min).round(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
