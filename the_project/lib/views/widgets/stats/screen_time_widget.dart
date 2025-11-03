import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_project/views/themes/style_simple/colors.dart';
import 'dart:math';

class ScreenTimeWidget extends StatelessWidget {
  final Map<String, double> screenTime;
  final Duration animationDuration;
  final Curve animationCurve;

  const ScreenTimeWidget({
    super.key,
    required this.screenTime,
    this.animationDuration = const Duration(milliseconds: 420),
    this.animationCurve = Curves.easeInOutCubic,
  });

  String get _headline {
    final total = screenTime.values.reduce((a, b) => a + b);
    return '${total.toStringAsFixed(1)} h/day';
  }

  String capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: animationDuration,
      curve: animationCurve,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Screen time', style: GoogleFonts.poppins(fontSize: 12)),
          const SizedBox(height: 8),
          Text(_headline, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          for (var e in screenTime.entries) ...[
            Text(capitalize(e.key), style: GoogleFonts.poppins(fontSize: 12)),
            const SizedBox(height: 6),
            Stack(
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.card.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                LayoutBuilder(builder: (context, cons) {
                  final maxWidth = cons.maxWidth;
                  final percent = (e.value / max(1.0, (screenTime.values.reduce(max)))).clamp(0.05, 1.0);
                  return Container(
                    height: 12,
                    width: maxWidth * percent,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        AppColors.coral.withOpacity(0.95),
                        AppColors.peach.withOpacity(0.95)
                      ]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 12),
          ]
        ],
      ),
    );
  }
}