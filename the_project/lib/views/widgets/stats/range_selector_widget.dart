import 'package:flutter/material.dart';
import 'package:the_project/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_project/views/themes/style_simple/colors.dart';

enum StatsRange { today, weekly, monthly, yearly }

class RangeSelectorWidget extends StatelessWidget {
  final StatsRange selectedRange;
  final Function(StatsRange) onRangeSelected;
  final Duration animationDuration;
  final Curve animationCurve;

  const RangeSelectorWidget({
    super.key,
    required this.selectedRange,
    required this.onRangeSelected,
    this.animationDuration = const Duration(milliseconds: 420),
    this.animationCurve = Curves.easeInOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final tabs = {
      StatsRange.today: t.today,
      StatsRange.weekly: t.weekly,
      StatsRange.monthly: t.monthly,
      StatsRange.yearly: t.yearly,
    };

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.35),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: tabs.entries.map((entry) {
          final isSelected = entry.key == selectedRange;
          return Expanded(
            child: GestureDetector(
              onTap: () => onRangeSelected(entry.key),
              child: AnimatedContainer(
                duration: animationDuration,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.card : AppColors.transparent,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.textPrimary.withOpacity(0.08),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    entry.value,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
