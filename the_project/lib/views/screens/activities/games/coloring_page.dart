import 'dart:math' as Math;
import 'package:flutter/material.dart';
import '../../../widgets/activity_shell.dart';
import '../../../themes/style_simple/colors.dart';

class ColoringPage extends StatefulWidget {
  const ColoringPage({super.key});

  @override
  State<ColoringPage> createState() => _ColoringPageState();
}

class _ColoringPageState extends State<ColoringPage> {
  int _template = 0; // 0..5
  Color _current = const Color(0xFF3ECF8E);

  // Editable palette; user can replace any swatch
  final List<Color> _palette = [
    const Color(0xFF1E3A5F),
    const Color(0xFFE53935),
    const Color(0xFF3ECF8E),
    const Color(0xFFFFC107),
    const Color(0xFF42A5F5),
    const Color(0xFFBA68C8),
    const Color(0xFFFF7043),
    const Color(0xFFFFEB3B),
    const Color(0xFF8D6E63),
    const Color(0xFFFFFFFF),
  ];

  final List<_FillAction> _history = [];
  final List<_FillAction> _redo = [];

  void _onFill(int regionIndex, Color previous, Color next) {
    setState(() {
      _redo.clear();
      _history.add(_FillAction(_template, regionIndex, previous, next));
    });
  }

  void _undo() {
    if (_history.isEmpty) return;
    setState(() => _redo.add(_history.removeLast()));
  }

  void _redoAct() {
    if (_redo.isEmpty) return;
    setState(() => _history.add(_redo.removeLast()));
  }

  void _clear() {
    setState(() {
      _history.removeWhere((a) => a.template == _template);
      _redo.clear();
    });
  }

  Future<void> _pickAndReplace(int index) async {
    final c = await showDialog<Color>(
      context: context,
      builder: (_) => _ColorPickerDialog(initial: _palette[index]),
    );
    if (c != null) {
      setState(() {
        _palette[index] = c;
        _current = c;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ActivityShell(
      title: 'Coloring',
      child: Column(
        children: [
          // Template chooser
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3EB),
                borderRadius: BorderRadius.circular(22),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(6, (i) {
                    return _TemplateChip(
                      label: _templateNames[i],
                      emoji: _templateEmojis[i],
                      selected: _template == i,
                      onTap: () {
                        setState(() => _template = i);
                      },
                    );
                  }),
                ),
              ),
            ),
          ),

          // Palette
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3EB),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (int i = 0; i < _palette.length; i++)
                            _Swatch(
                              color: _palette[i],
                              selected: _current.value == _palette[i].value,
                              onTap: () =>
                                  setState(() => _current = _palette[i]),
                              onLongPress: () => _pickAndReplace(i),
                            ),
                          _AddSwatch(
                            onTap: () async {
                              final c = await showDialog<Color>(
                                context: context,
                                builder: (_) =>
                                    _ColorPickerDialog(initial: _current),
                              );
                              if (c != null) {
                                setState(() {
                                  // replace last swatch with new color
                                  _palette[_palette.length - 1] = c;
                                  _current = c;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.palette_rounded,
                    color: AppColors.accentPink,
                  ),
                ],
              ),
            ),
          ),

          // Tools
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Tool(icon: Icons.undo_rounded, onTap: _undo),
                const SizedBox(width: 12),
                _Tool(icon: Icons.redo_rounded, onTap: _redoAct),
                const SizedBox(width: 12),
                _Tool(icon: Icons.cleaning_services_rounded, onTap: _clear),
                const SizedBox(width: 12),
                _Tool(
                  icon: Icons.download_rounded,
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Saved! (wire export later)'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Canvas
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  color: _templateBg(_template),
                  child: _ColoringCanvas(
                    template: _template,
                    currentColor: _current,
                    history: _history,
                    palette: _palette,
                    onFill: _onFill,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;
  const _TemplateChip({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.white.withOpacity(.6),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          width: 46,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? Colors.white : Colors.black26,
              width: selected ? 3 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.12),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddSwatch extends StatelessWidget {
  final VoidCallback onTap;
  const _AddSwatch({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Ink(
          width: 46,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black26),
          ),
          child: const Icon(Icons.add, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _Tool extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _Tool({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Ink(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _FillAction {
  final int template;
  final int regionIndex;
  final Color previous;
  final Color next;
  _FillAction(this.template, this.regionIndex, this.previous, this.next);
}

class _Region {
  Path Function(Size) pathBuilder;
  Color color;
  _Region(this.pathBuilder, this.color);
}

class _ColoringCanvas extends StatefulWidget {
  final int template; // 0..5
  final Color currentColor;
  final List<_FillAction> history;
  final List<Color> palette;
  final void Function(int regionIndex, Color previous, Color next) onFill;

  const _ColoringCanvas({
    required this.template,
    required this.currentColor,
    required this.history,
    required this.palette,
    required this.onFill,
  });

  @override
  State<_ColoringCanvas> createState() => _ColoringCanvasState();
}

class _ColoringCanvasState extends State<_ColoringCanvas> {
  late List<_Region> _regions;

  @override
  void initState() {
    super.initState();
    _regions = _buildRegions(widget.template);
  }

  @override
  void didUpdateWidget(covariant _ColoringCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.template != widget.template) {
      _regions = _buildRegions(widget.template);
    }
    // rebuild colors from history for this template
    final initial = _buildRegions(widget.template);
    for (final a in widget.history.where(
      (a) => a.template == widget.template,
    )) {
      initial[a.regionIndex].color = a.next;
    }
    _regions = initial;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final size = Size(c.maxWidth, c.maxHeight);
        return GestureDetector(
          onTapDown: (d) {
            final p = d.localPosition;
            for (int i = _regions.length - 1; i >= 0; i--) {
              final r = _regions[i];
              final path = r.pathBuilder(size);
              if (path.contains(p)) {
                final before = r.color;
                final after = widget.currentColor;
                if (before.value != after.value) {
                  widget.onFill(i, before, after);
                }
                break;
              }
            }
          },
          child: CustomPaint(painter: _ScenePainter(_regions), size: size),
        );
      },
    );
  }

  /// Build six different sets of regions (simple, tappable comic shapes)
  List<_Region> _buildRegions(int t) {
    switch (t) {
      case 0:
        return _tplSpace();
      case 1:
        return _tplGarden();
      case 2:
        return _tplFish();
      case 3:
        return _tplButterfly();
      case 4:
        return _tplHouse();
      case 5:
      default:
        return _tplMandala();
    }
  }

  List<_Region> _tplSpace() {
    return [
      _r((s) => _star(s, const Offset(.18, .25), .03), Colors.yellow),
      _r((s) => _star(s, const Offset(.78, .22), .035), Colors.yellow),
      _r((s) => _star(s, const Offset(.64, .40), .03), Colors.yellow),
      _r((s) => _star(s, const Offset(.32, .52), .03), Colors.yellow),
      _r((s) => _star(s, const Offset(.86, .60), .03), Colors.yellow),
      _r((s) => _star(s, const Offset(.14, .70), .03), Colors.yellow),
      _r(
        (s) => Path()..addOval(_rectCircle(s, const Offset(.5, .62), .22)),
        const Color(0xFFFFF176),
      ), // sun
      _r(
        (s) => Path()..addOval(_rectCircle(s, const Offset(.25, .73), .11)),
        const Color(0xFFAA47BC),
      ),
      _r(
        (s) => Path()..addOval(_rectCircle(s, const Offset(.78, .76), .10)),
        const Color(0xFF3ECF8E),
      ),
      _r(
        (s) => Path()..addOval(_rectCircle(s, const Offset(.60, .28), .08)),
        const Color(0xFF42A5F5),
      ),
      _r(
        (s) => Path()..addOval(_rectCircle(s, const Offset(.35, .34), .10)),
        const Color(0xFFFF80AB),
      ),
      _r(
        (s) => Path()..addOval(_rectCircle(s, const Offset(.50, .90), .10)),
        const Color(0xFFFF7043),
      ),
      _r(
        (s) => Path()..addOval(_rectCircle(s, const Offset(.14, .46), .065)),
        const Color(0xFFD32F2F),
      ),
      _r(
        (s) => Path()..addOval(_rectCircle(s, const Offset(.88, .46), .075)),
        const Color(0xFF1E88E5),
      ),
      _r((s) {
        final center = _pt(s, const Offset(.78, .76));
        final rect = Rect.fromCenter(
          center: center,
          width: s.width * .16,
          height: s.height * .035,
        );
        return Path()..addOval(rect);
      }, const Color(0xFFB2DFDB)), // ring
    ];
  }

  List<_Region> _tplGarden() {
    return [
      _r(
        (s) => _leaf(s, const Offset(.25, .70), .2, .12),
        const Color(0xFF66BB6A),
      ),
      _r(
        (s) => _leaf(s, const Offset(.40, .72), .22, .12),
        const Color(0xFF81C784),
      ),
      _r(
        (s) => _leaf(s, const Offset(.55, .70), .2, .12),
        const Color(0xFF66BB6A),
      ),
      _r(
        (s) => _flower(s, const Offset(.70, .45), .16),
        const Color(0xFFFFCDD2),
      ),
      _r(
        (s) => Path()
          ..addRect(Rect.fromLTWH(0, s.height * .82, s.width, s.height * .18)),
        const Color(0xFF8D6E63),
      ),
      _r((s) => _sun(s, const Offset(.17, .22), .11), const Color(0xFFFFF176)),
      _r((s) => _cloud(s, const Offset(.55, .22), .18), Colors.white),
    ];
  }

  List<_Region> _tplFish() {
    return [
      _r(
        (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height)),
        const Color(0xFF113B5C),
      ),
      _r((s) => _fish(s, const Offset(.35, .55), .16), const Color(0xFFFFB74D)),
      _r((s) => _fish(s, const Offset(.70, .40), .13), const Color(0xFF42A5F5)),
      _r((s) => _bubble(s, const Offset(.18, .35), .025), Colors.white),
      _r((s) => _bubble(s, const Offset(.22, .30), .02), Colors.white),
      _r((s) => _bubble(s, const Offset(.26, .26), .015), Colors.white),
      _r(
        (s) => _seaweed(s, const Offset(.12, .80), .22),
        const Color(0xFF2E7D32),
      ),
      _r(
        (s) => _seaweed(s, const Offset(.90, .85), .20),
        const Color(0xFF388E3C),
      ),
    ];
  }

  List<_Region> _tplButterfly() {
    return [
      _r(
        (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height)),
        const Color(0xFFE3F2FD),
      ),
      _r(
        (s) => _wing(s, const Offset(.40, .55), .22, left: true),
        const Color(0xFFFF8A80),
      ),
      _r(
        (s) => _wing(s, const Offset(.60, .55), .22, left: false),
        const Color(0xFF80DEEA),
      ),
      _r(
        (s) => Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: _pt(s, const Offset(.5, .55)),
                width: s.width * .06,
                height: s.height * .28,
              ),
              const Radius.circular(10),
            ),
          ),
        const Color(0xFF5D4037),
      ),
      _r(
        (s) => _antenna(s, const Offset(.5, .42), true),
        const Color(0xFF5D4037),
      ),
      _r(
        (s) => _antenna(s, const Offset(.5, .42), false),
        const Color(0xFF5D4037),
      ),
    ];
  }

  List<_Region> _tplHouse() {
    return [
      _r(
        (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height)),
        const Color(0xFFB3E5FC),
      ),
      _r((s) => _houseBody(s), const Color(0xFFFFF8E1)),
      _r((s) => _roof(s), const Color(0xFFD32F2F)),
      _r((s) => _door(s), const Color(0xFF8D6E63)),
      _r((s) => _window(s, const Offset(.42, .58)), Colors.white),
      _r((s) => _window(s, const Offset(.58, .58)), Colors.white),
      _r((s) => _sun(s, const Offset(.15, .18), .10), const Color(0xFFFFF176)),
      _r((s) => _cloud(s, const Offset(.70, .18), .20), Colors.white),
      _r(
        (s) => Path()
          ..addRect(Rect.fromLTWH(0, s.height * .86, s.width, s.height * .14)),
        const Color(0xFF9CCC65),
      ),
    ];
  }

  List<_Region> _tplMandala() {
    return [
      _r(
        (s) => Path()..addRect(Rect.fromLTWH(0, 0, s.width, s.height)),
        const Color(0xFF0E2433),
      ),
      for (final r in [0.42, 0.32, 0.24, 0.17, 0.11, 0.07])
        _r(
          (s) => Path()..addOval(_rectCircle(s, const Offset(.5, .55), r)),
          Colors.white.withOpacity(.95),
        ),
      // petals
      for (int i = 0; i < 12; i++)
        _r((s) {
          final a = i * (2 * Math.pi / 12);
          return _petal(s, const Offset(.5, .55), .46, a);
        }, const Color(0xFFB2DFDB)),
    ];
  }

  _Region _r(Path Function(Size) b, Color c) => _Region(b, c);

  static Offset _pt(Size s, Offset rel) =>
      Offset(s.width * rel.dx, s.height * rel.dy);
  static Rect _rectCircle(Size s, Offset relCenter, double relRadius) =>
      Rect.fromCircle(
        center: _pt(s, relCenter),
        radius: s.shortestSide * relRadius,
      );

  static Path _star(Size s, Offset relCenter, double relR) {
    final c = _pt(s, relCenter);
    final R = s.shortestSide * relR;
    final r = R * .5;
    const n = 5;
    final path = Path();
    for (int i = 0; i < n * 2; i++) {
      final a = (i * Math.pi / n);
      final rr = i.isEven ? R : r;
      final p = Offset(c.dx + rr * Math.cos(a), c.dy + rr * Math.sin(a));
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    return path;
  }

  static Path _sun(Size s, Offset relCenter, double relR) {
    final p = Path()..addOval(_rectCircle(s, relCenter, relR));
    // rays
    final c = _pt(s, relCenter);
    final R = s.shortestSide * (relR + .03);
    for (int i = 0; i < 12; i++) {
      final a = i * (2 * Math.pi / 12);
      p.addPolygon([
        Offset(
          c.dx + (R - 10) * Math.cos(a - .2),
          c.dy + (R - 10) * Math.sin(a - .2),
        ),
        Offset(c.dx + (R + 6) * Math.cos(a), c.dy + (R + 6) * Math.sin(a)),
        Offset(
          c.dx + (R - 10) * Math.cos(a + .2),
          c.dy + (R - 10) * Math.sin(a + .2),
        ),
      ], true);
    }
    return p;
  }

  static Path _cloud(Size s, Offset relCenter, double relW) {
    final c = _pt(s, relCenter);
    final w = s.width * relW;
    final h = w * .45;
    final r = RRect.fromRectAndRadius(
      Rect.fromCenter(center: c, width: w, height: h),
      const Radius.circular(50),
    );
    final p = Path()..addRRect(r);
    p.addOval(
      Rect.fromCircle(center: c + Offset(-w * .25, -h * .3), radius: h * .55),
    );
    p.addOval(
      Rect.fromCircle(center: c + Offset(w * .05, -h * .38), radius: h * .65),
    );
    p.addOval(
      Rect.fromCircle(center: c + Offset(w * .3, -h * .22), radius: h * .5),
    );
    return p;
  }

  static Path _leaf(Size s, Offset relCenter, double relW, double relH) {
    final c = _pt(s, relCenter);
    final w = s.width * relW;
    final h = s.height * relH;
    final p = Path();
    p.moveTo(c.dx, c.dy - h / 2);
    p.quadraticBezierTo(c.dx + w / 2, c.dy - h / 2, c.dx + w / 2, c.dy);
    p.quadraticBezierTo(c.dx + w / 2, c.dy + h / 2, c.dx, c.dy + h / 2);
    p.quadraticBezierTo(c.dx - w / 2, c.dy + h / 2, c.dx - w / 2, c.dy);
    p.quadraticBezierTo(c.dx - w / 2, c.dy - h / 2, c.dx, c.dy - h / 2);
    p.close();
    return p;
  }

  static Path _flower(Size s, Offset relCenter, double relR) {
    final c = _pt(s, relCenter);
    final R = s.shortestSide * relR;
    final p = Path();

    // petals (add multiple petal shapes around the center)
    for (int i = 0; i < 6; i++) {
      final a = i * (2 * Math.pi / 6);
      final tip = Offset(c.dx + R * Math.cos(a), c.dy + R * Math.sin(a));
      final left = Offset(
        c.dx + R * .55 * Math.cos(a - .5),
        c.dy + R * .55 * Math.sin(a - .5),
      );
      final right = Offset(
        c.dx + R * .55 * Math.cos(a + .5),
        c.dy + R * .55 * Math.sin(a + .5),
      );

      final petal = Path();
      petal.moveTo(c.dx, c.dy);
      petal.quadraticBezierTo(left.dx, left.dy, tip.dx, tip.dy);
      petal.quadraticBezierTo(right.dx, right.dy, c.dx, c.dy);
      petal.close();

      p.addPath(petal, Offset.zero);
    }

    // center circle
    p.addOval(Rect.fromCircle(center: c, radius: R * .32));
    return p;
  }

  static Path _fish(Size s, Offset relCenter, double relR) {
    final c = _pt(s, relCenter);
    final r = s.shortestSide * relR;
    final body = Rect.fromCenter(center: c, width: r * 2.2, height: r * 1.3);
    final p = Path()
      ..addRRect(RRect.fromRectAndRadius(body, Radius.circular(r)));
    // tail
    p.addPolygon([
      c + Offset(r * 1.1, 0),
      c + Offset(r * 1.8, -r * .8),
      c + Offset(r * 1.5, 0),
      c + Offset(r * 1.8, r * .8),
    ], true);
    return p;
  }

  static Path _bubble(Size s, Offset relCenter, double relR) =>
      Path()..addOval(_rectCircle(s, relCenter, relR));

  static Path _seaweed(Size s, Offset relBottom, double relH) {
    final b = _pt(s, relBottom);
    final h = s.height * relH;
    final p = Path();
    p.moveTo(b.dx - 8, b.dy);
    p.cubicTo(
      b.dx,
      b.dy - h * .3,
      b.dx - 20,
      b.dy - h * .6,
      b.dx + 6,
      b.dy - h,
    );
    p.cubicTo(
      b.dx + 20,
      b.dy - h * .6,
      b.dx - 10,
      b.dy - h * .3,
      b.dx + 8,
      b.dy,
    );
    p.close();
    return p;
  }

  static Path _wing(
    Size s,
    Offset relCenter,
    double relR, {
    required bool left,
  }) {
    final c = _pt(s, relCenter);
    final r = s.shortestSide * relR;
    final sign = left ? -1.0 : 1.0;
    final p = Path();
    p.moveTo(c.dx, c.dy);
    p.quadraticBezierTo(
      c.dx + sign * r * .6,
      c.dy - r * .6,
      c.dx + sign * r,
      c.dy,
    );
    p.quadraticBezierTo(c.dx + sign * r * .6, c.dy + r * .6, c.dx, c.dy);
    p.close();
    return p;
  }

  static Path _antenna(Size s, Offset relTop, bool left) {
    final t = _pt(s, relTop);
    final sign = left ? -1.0 : 1.0;
    final p = Path();
    p.moveTo(t.dx, t.dy);
    p.quadraticBezierTo(
      t.dx + sign * 30,
      t.dy - 40,
      t.dx + sign * 46,
      t.dy - 10,
    );
    return p..close();
  }

  static Path _houseBody(Size s) {
    final w = s.width * .46;
    final h = s.height * .36;
    final c = _pt(s, const Offset(.5, .62));
    return Path()..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: w, height: h),
        const Radius.circular(16),
      ),
    );
  }

  static Path _roof(Size s) {
    final c = _pt(s, const Offset(.5, .44));
    final w = s.width * .52;
    final h = s.height * .16;
    return Path()..addPolygon([
      c + Offset(-w / 2, h / 2),
      c + Offset(0, -h / 2),
      c + Offset(w / 2, h / 2),
    ], true);
  }

  static Path _door(Size s) {
    final c = _pt(s, const Offset(.5, .68));
    final w = s.width * .10;
    final h = s.height * .20;
    return Path()..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: w, height: h),
        const Radius.circular(8),
      ),
    );
  }

  static Path _window(Size s, Offset relCenter) {
    final c = _pt(s, relCenter);
    final w = s.width * .10;
    final h = s.height * .10;
    return Path()..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: w, height: h),
        const Radius.circular(8),
      ),
    );
  }

  static Path _petal(Size s, Offset relC, double relR, double angle) {
    final c = _pt(s, relC);
    final R = s.shortestSide * relR;
    final p = Path();
    final a = angle;
    final tip = Offset(c.dx + R * Math.cos(a), c.dy + R * Math.sin(a));
    final left = Offset(
      c.dx + R * .55 * Math.cos(a - .5),
      c.dy + R * .55 * Math.sin(a - .5),
    );
    final right = Offset(
      c.dx + R * .55 * Math.cos(a + .5),
      c.dy + R * .55 * Math.sin(a + .5),
    );
    p.moveTo(c.dx, c.dy);
    p.quadraticBezierTo(left.dx, left.dy, tip.dx, tip.dy);
    p.quadraticBezierTo(right.dx, right.dy, c.dx, c.dy);
    p.close();
    return p;
  }
}

class _ScenePainter extends CustomPainter {
  final List<_Region> regions;
  _ScenePainter(this.regions);

  @override
  void paint(Canvas canvas, Size size) {
    for (final r in regions) {
      final path = r.pathBuilder(size);
      final fill = Paint()..color = r.color;
      canvas.drawPath(path, fill);

      // comic outline
      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Colors.black.withOpacity(.75)
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _ScenePainter oldDelegate) =>
      oldDelegate.regions != regions;
}

/// ---------- Color picker (no packages) ----------

class _ColorPickerDialog extends StatefulWidget {
  final Color initial;
  const _ColorPickerDialog({required this.initial});

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late double h; // 0..360
  late double s; // 0..1
  late double v; // 0..1
  late double a; // 0..1

  @override
  void initState() {
    super.initState();
    final hsv = HSVColor.fromColor(widget.initial);
    h = hsv.hue;
    s = hsv.saturation;
    v = hsv.value;
    a = widget.initial.opacity;
  }

  Color get color => HSVColor.fromAHSV(a, h, s, v).toColor();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(18),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pick a color',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _Preview(color: color),
            const SizedBox(height: 12),
            _LabeledSlider(
              label: 'Hue',
              value: h,
              min: 0,
              max: 360,
              onChanged: (x) => setState(() => h = x),
            ),
            _LabeledSlider(
              label: 'Saturation',
              value: s,
              min: 0,
              max: 1,
              onChanged: (x) => setState(() => s = x),
            ),
            _LabeledSlider(
              label: 'Brightness',
              value: v,
              min: 0,
              max: 1,
              onChanged: (x) => setState(() => v = x),
            ),
            _LabeledSlider(
              label: 'Opacity',
              value: a,
              min: 0,
              max: 1,
              onChanged: (x) => setState(() => a = x),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentPink,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Use color'),
                  onPressed: () => Navigator.pop(context, color),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  final Color color;
  const _Preview({required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
    );
  }
}

class _LabeledSlider extends StatelessWidget {
  final String label;
  final double value, min, max;
  final ValueChanged<double> onChanged;
  const _LabeledSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 88, child: Text(label)),
        Expanded(
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
        SizedBox(
          width: 56,
          child: Text(
            value.toStringAsFixed(min == 0 && max == 360 ? 0 : 2),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

const _templateNames = [
  'Space',
  'Garden',
  'Fish',
  'Butterfly',
  'House',
  'Mandala',
];

const _templateEmojis = ['🪐', '🌼', '🐟', '🦋', '🏠', '🌀'];

Color _templateBg(int t) {
  switch (t) {
    case 0:
      return const Color(0xFF113B5C); // space deep blue
    case 1:
      return const Color(0xFFE8F5E9);
    case 2:
      return const Color(0xFF0E3B55);
    case 3:
      return const Color(0xFFE3F2FD);
    case 4:
      return const Color(0xFFB3E5FC);
    case 5:
      return const Color(0xFF0E2433);
    default:
      return Colors.white;
  }
}
