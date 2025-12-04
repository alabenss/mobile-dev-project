import 'dart:math';
import 'package:flutter/material.dart';
import 'package:the_project/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_project/views/themes/style_simple/colors.dart';

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

  String _categoryLabel(AppLocalizations t, String key) {
    switch (key) {
      case 'social':
        return t.social;
      case 'entertainment':
        return t.entertainment;
      case 'productivity':
        return t.productivity;
      default:
        if (key.isEmpty) return key;
        return key[0].toUpperCase() + key.substring(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final total = screenTime.isEmpty
        ? 0.0
        : screenTime.values.reduce((a, b) => a + b);
    final headline = t.hoursPerDay(total.toStringAsFixed(1));

    return AnimatedContainer(
      duration: animationDuration,
      curve: animationCurve,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.screenTime, style: GoogleFonts.poppins(fontSize: 12)),
          const SizedBox(height: 8),
          Text(headline,
              style:
                  GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          for (var e in screenTime.entries) ...[
            Text(
              _categoryLabel(t, e.key),
              style: GoogleFonts.poppins(fontSize: 12),
            ),
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
                  final maxVal = max(1.0, screenTime.values.reduce(max));
                  final percent = (e.value / maxVal).clamp(0.05, 1.0);
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
