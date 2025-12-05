import 'package:flutter/material.dart';
import 'package:the_project/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_project/views/themes/style_simple/colors.dart';
import 'range_selector_widget.dart';

class ScreenTimeWidget extends StatelessWidget {
  final Map<String, double> screenTime;
  final StatsRange selectedRange;
  final Duration animationDuration;
  final Curve animationCurve;

  const ScreenTimeWidget({
    super.key,
    required this.screenTime,
    required this.selectedRange,
    this.animationDuration = const Duration(milliseconds: 420),
    this.animationCurve = Curves.easeInOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    // Get detox value (this is now the SUM of all detox values for the period)
    final detoxTotalValue = screenTime['detox'] ?? 0.0;
    
    // Calculate the percentage based on range
    double displayPercentage;
    String rangeLabel = '';
    
    switch (selectedRange) {
      case StatsRange.today:
        // For today: just multiply by 100
        displayPercentage = detoxTotalValue * 100;
        rangeLabel = '';
        break;
      case StatsRange.weekly:
        // For weekly: sum / 7, then multiply by 100
        displayPercentage = (detoxTotalValue / 7) * 100;
        rangeLabel = ' / day';
        break;
      case StatsRange.monthly:
        // For monthly: sum / 30, then multiply by 100
        displayPercentage = (detoxTotalValue / 30) * 100;
        rangeLabel = ' / day';
        break;
      case StatsRange.yearly:
        // For yearly: sum / 365, then multiply by 100
        displayPercentage = (detoxTotalValue / 365) * 100;
        rangeLabel = ' / day';
        break;
    }
    
    // Format the percentage display
    final percentageText = displayPercentage.toStringAsFixed(2);
    
    // For progress bar, normalize the value (assuming max detox per day is 1.0)
    final progressValue = selectedRange == StatsRange.today
        ? detoxTotalValue.clamp(0.0, 1.0)
        : (displayPercentage / 100).clamp(0.0, 1.0);
    
    // Determine status message based on display percentage
    String statusMessage;
    Color statusColor;
    
    if (displayPercentage >= 80) {
      statusMessage = t.detoxExcellent ?? 'Excellent Progress!';
      statusColor = AppColors.mint;
    } else if (displayPercentage >= 60) {
      statusMessage = t.detoxGood ?? 'Good Progress';
      statusColor = AppColors.sky;
    } else if (displayPercentage >= 40) {
      statusMessage = t.detoxModerate ?? 'Moderate Progress';
      statusColor = AppColors.peach;
    } else if (displayPercentage >= 20) {
      statusMessage = t.detoxLow ?? 'Keep Going';
      statusColor = AppColors.coral;
    } else {
      statusMessage = t.detoxStart ?? 'Just Starting';
      statusColor = AppColors.textPrimary.withOpacity(0.5);
    }

    return AnimatedContainer(
      duration: animationDuration,
      curve: animationCurve,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.detoxProgress ?? 'Detox Progress',
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textPrimary.withOpacity(0.6))),
          const SizedBox(height: 8),

          // Main progress display
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$percentageText%',
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
              if (selectedRange != StatsRange.today)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, left: 4),
                  child: Text(
                    rangeLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textPrimary.withOpacity(0.5),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    statusMessage,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textPrimary.withOpacity(0.7),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress bar
          Stack(
            children: [
              // Background bar
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.card.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              // Progress bar
              LayoutBuilder(builder: (context, cons) {
                final maxWidth = cons.maxWidth;
                final progressWidth = maxWidth * progressValue;

                return AnimatedContainer(
                  duration: animationDuration,
                  curve: animationCurve,
                  height: 20,
                  width: progressWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        statusColor.withOpacity(0.8),
                        statusColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),

          const SizedBox(height: 12),

          // Info text
          Text(
            t.detoxInfo ?? 'Average detox progress for the selected period',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textPrimary.withOpacity(0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}