import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../../../themes/style_simple/colors.dart';
import '../../../widgets/app_background.dart';

/// A soothing breathing exercise screen:
/// - 1 minute session (00:00 -> 01:00)
/// - Start/Stop
/// - Expanding/contracting flower (lotus) synced to breath cycle
///
/// Drop-in screen: push it with
/// Navigator.push(context, MaterialPageRoute(builder: (_) => const BreathPage()));
class BreathPage extends StatefulWidget {
  const BreathPage({super.key});

  @override
  State<BreathPage> createState() => _BreathPageState();
}

class _BreathPageState extends State<BreathPage> with TickerProviderStateMixin {
  /// One breath cycle (inhale + exhale). Tweak to your taste.
  static const Duration _cycle = Duration(seconds: 6); // 4s in + 2s out feel
  static const Duration _session = Duration(minutes: 1);

  late final AnimationController _breathCtrl;
  late final Animation<double> _scale;

  Timer? _countdownTimer;
  Duration _remaining = _session;
  bool _running = false;

  @override
  void initState() {
    super.initState();

    // Repeating inhale/exhale loop
    _breathCtrl = AnimationController(vsync: this, duration: _cycle);

    // Scale between 0.8 -> 1.0 (inhale), then 1.0 -> 0.8 (exhale)
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: .82, end: 1.0).chain(CurveTween(curve: Curves.easeOutCubic)), weight: 4),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: .82).chain(CurveTween(curve: Curves.easeInCubic)), weight: 2),
    ]).animate(_breathCtrl);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _breathCtrl.dispose();
    super.dispose();
  }

  void _start() {
    if (_running) return;
    setState(() {
      _running = true;
      _remaining = _session;
    });

    _breathCtrl
      ..reset()
      ..repeat();

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _remaining -= const Duration(seconds: 1);
        if (_remaining.inSeconds <= 0) {
          _stop(resetToZero: false); // stop at 00:00
        }
      });
    });
  }

  void _stop({bool resetToZero = true}) {
    _countdownTimer?.cancel();
    _breathCtrl.stop();
    setState(() {
      _running = false;
      _remaining = resetToZero ? Duration.zero : Duration.zero;
    });
  }

  String _fmt(Duration d) {
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
  title: const Text(
    'Breath',
    style: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 20,
      color: Colors.white,
    ),
  ),
  centerTitle: true,
  backgroundColor: Colors.transparent,
  elevation: 0,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
    onPressed: () => Navigator.of(context).pop(),
  ),
),

        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                // Main soft card
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1E9), // soft peach
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                    child: Column(
                      children: [
                        const SizedBox(height: 6),
                        const Text(
                          'Take a deep breath and let your body wind down\nfor the day.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            height: 1.35,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _fmt(_remaining),
                          style: const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Breathing flower in white circle
                        Expanded(
                          child: Center(
                            child: AnimatedBuilder(
                              animation: _breathCtrl,
                              builder: (_, __) {
                                return Container(
                                  width: 320,
                                  height: 320,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  alignment: Alignment.center,
                                  child: Transform.scale(
                                    scale: _scale.value,
                                    child: const _LotusFlower(), // change to _TulipFlower() for alternative look
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Primary button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _running ? _stop : _start,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFBF8E7A), // warm brown like mock
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            child: Text(_running ? 'Stop' : 'Start'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ---------- FLOWER WIDGETS (no assets needed) ----------

/// Gentle lotus drawn with overlapping rounded petals.
class _LotusFlower extends StatelessWidget {
  const _LotusFlower();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(220, 220),
      painter: _LotusPainter(),
    );
  }
}

class _LotusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 22);
    final petalPaints = [
      Paint()..color = const Color(0xFF8FD1FF).withOpacity(.85),
      Paint()..color = const Color(0xFF68BFF6).withOpacity(.85),
      Paint()..color = const Color(0xFF4FB0EA).withOpacity(.85),
    ];

    // Draw three layers of mirrored petals
    void drawPetal(double w, double h, double angle, Paint p) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      final r = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, 0), width: w, height: h),
        const Radius.circular(90),
      );
      canvas.drawRRect(r, p);
      canvas.restore();
    }

    // back layer
    drawPetal(210, 90, 0, petalPaints[0]);
    drawPetal(210, 90, pi / 8, petalPaints[0]);
    drawPetal(210, 90, -pi / 8, petalPaints[0]);

    // middle layer
    drawPetal(180, 76, 0, petalPaints[1]);
    drawPetal(180, 76, pi / 9, petalPaints[1]);
    drawPetal(180, 76, -pi / 9, petalPaints[1]);

    // front layer
    drawPetal(150, 64, 0, petalPaints[2]);

    // tiny heart/seed
    final heart = Paint()..color = const Color(0xFFEAA39A);
    canvas.drawCircle(Offset(center.dx, center.dy - 4), 16, heart);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Alternative minimalist tulip (swap in the AnimatedBuilder if you want another look).
class _TulipFlower extends StatelessWidget {
  const _TulipFlower();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 200),
      painter: _TulipPainter(),
    );
  }
}

class _TulipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final petal = Paint()..color = const Color(0xFF6CC3FF).withOpacity(.9);

    Path tear(double radius, double sharpness) {
      final p = Path();
      p.moveTo(c.dx, c.dy - radius);
      p.quadraticBezierTo(
        c.dx + radius * .9,
        c.dy - radius * .2,
        c.dx,
        c.dy + radius * sharpness,
      );
      p.quadraticBezierTo(
        c.dx - radius * .9,
        c.dy - radius * .2,
        c.dx,
        c.dy - radius,
      );
      p.close();
      return p;
    }

    canvas.drawPath(tear(70, .6), petal);
    canvas.save();
    canvas.translate(-36, 10);
    canvas.drawPath(tear(52, .6), petal..color = petal.color.withOpacity(.75));
    canvas.restore();

    canvas.save();
    canvas.translate(36, 10);
    canvas.drawPath(tear(52, .6), petal..color = petal.color.withOpacity(.75));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
