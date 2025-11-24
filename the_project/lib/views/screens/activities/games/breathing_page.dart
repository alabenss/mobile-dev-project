import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../logic/activities/games/breathing_cubit.dart';
import '../../../../logic/activities/games/breathing_state.dart';

import '../../../themes/style_simple/colors.dart';
import '../../../themes/style_simple/app_background.dart';

class BreathPage extends StatefulWidget {
  const BreathPage({super.key});

  @override
  State<BreathPage> createState() => _BreathPageState();
}

class _BreathPageState extends State<BreathPage>
    with TickerProviderStateMixin {
  /// One breath cycle (inhale + exhale).
  static const Duration _cycle = Duration(seconds: 6); // 4s in + 2s out

  late final AnimationController _breathCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    // Repeating inhale/exhale loop
    _breathCtrl = AnimationController(vsync: this, duration: _cycle);

    // Scale between 0.82 -> 1.0 (inhale), then 1.0 -> 0.82 (exhale)
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: .82, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 4,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: .82)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 2,
      ),
    ]).animate(_breathCtrl);
  }

  @override
  void dispose() {
    _breathCtrl.dispose();
    super.dispose();
  }

  void _start() {
    final cubit = context.read<BreathingCubit>();
    if (cubit.state.running) return;

    _breathCtrl
      ..reset()
      ..repeat();

    cubit.startSession();
  }

  void _stop() {
    final cubit = context.read<BreathingCubit>();

    _breathCtrl.stop();
    cubit.stopSession(resetToZero: true);
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
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: BlocBuilder<BreathingCubit, BreathingState>(
              builder: (context, state) {
                final running = state.running;
                final remaining = state.remaining;

                return Column(
                  children: [
                    // Main soft card
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1E9), // soft peach
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding:
                            const EdgeInsets.fromLTRB(18, 18, 18, 14),
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
                              _fmt(remaining),
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
                                        child: const _LotusFlower(),
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
                                onPressed: running ? _stop : _start,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFFBF8E7A), // warm brown
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(18),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                child: Text(running ? 'Stop' : 'Start'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

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

    void drawPetal(double w, double h, double angle, Paint p) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      final r = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: const Offset(0, 0),
          width: w,
          height: h,
        ),
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
    canvas.drawPath(
      tear(52, .6),
      petal..color = petal.color.withOpacity(.75),
    );
    canvas.restore();

    canvas.save();
    canvas.translate(36, 10);
    canvas.drawPath(
      tear(52, .6),
      petal..color = petal.color.withOpacity(.75),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
