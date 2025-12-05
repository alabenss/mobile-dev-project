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

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    // Get detox value (0.0 to 1.0)
    final detoxValue = screenTime['detox'] ?? 0.0;
    
    // Convert to percentage
    final detoxPercentage = (detoxValue * 100).toStringAsFixed(0);
    
    // Determine status message based on detox value
    String statusMessage;
    Color statusColor;
    
    if (detoxValue >= 0.8) {
      statusMessage = t.detoxExcellent ?? 'Excellent Progress!';
      statusColor = AppColors.mint;
    } else if (detoxValue >= 0.6) {
      statusMessage = t.detoxGood ?? 'Good Progress';
      statusColor = AppColors.sky;
    } else if (detoxValue >= 0.4) {
      statusMessage = t.detoxModerate ?? 'Moderate Progress';
      statusColor = AppColors.peach;
    } else if (detoxValue >= 0.2) {
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
          Text(
            t.detoxProgress ?? 'Detox Progress', 
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textPrimary.withOpacity(0.6)
            )
          ),
          const SizedBox(height: 8),
          
          // Main progress display
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$detoxPercentage%',
                style: GoogleFonts.poppins(
                  fontSize: 32, 
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  statusMessage,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textPrimary.withOpacity(0.7),
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
                final progressWidth = maxWidth * detoxValue.clamp(0.0, 1.0);
                
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