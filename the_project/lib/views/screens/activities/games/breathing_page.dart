import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_project/l10n/app_localizations.dart';

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
  static const Duration _cycle = Duration(seconds: 6);

  late final AnimationController _breathCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _breathCtrl = AnimationController(vsync: this, duration: _cycle);

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
    final l10n = AppLocalizations.of(context)!; // <-- added

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            l10n.breathingTitle, // was: 'Breath'
            style: const TextStyle(
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
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1E9),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding:
                            const EdgeInsets.fromLTRB(18, 18, 18, 14),
                        child: Column(
                          children: [
                            const SizedBox(height: 6),
                            Text(
                              l10n.breathingDescription,
                              // was: 'Take a deep breath and let your body wind down\nfor the day.'
                              textAlign: TextAlign.center,
                              style: const TextStyle(
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
                                        child: Image.asset(
                                          'assets/images/heart.png',
                                          width: 220,
                                          height: 220,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: running ? _stop : _start,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFFBF8E7A),
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
                                child: Text(
                                  running
                                      ? l10n.breathingStop
                                      : l10n.breathingStart,
                                  // was: running ? 'Stop' : 'Start'
                                ),
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
