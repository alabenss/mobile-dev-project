import 'dart:math';
import 'package:flutter/material.dart';
import 'package:the_project/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_project/views/themes/style_simple/colors.dart';
import 'range_selector_widget.dart';

class JournalingStatsWidget extends StatelessWidget {
  final int journalingCount;
  final StatsRange selectedRange;
  final List<String> labels;
  final Duration animationDuration;
  final Curve animationCurve;

  const JournalingStatsWidget({
    super.key,
    required this.journalingCount,
    required this.selectedRange,
    required this.labels,
    this.animationDuration = const Duration(milliseconds: 420),
    this.animationCurve = Curves.easeInOutCubic,
  });

  /// Build day bubbles that show journal entries per day/period
  List<Widget> _buildDayBubbles(AppLocalizations t) {
    final list = <Widget>[];
    
    // Number of periods to show based on range
    final totalSlots = selectedRange == StatsRange.today
        ? 1
        : (selectedRange == StatsRange.weekly
            ? 7
            : (selectedRange == StatsRange.monthly ? 4 : 12));
    
    // Distribute journal entries across slots
    // For weekly: show entries per day
    // For monthly: show entries per week
    // For yearly: show entries per month
    final entriesPerSlot = journalingCount > 0 ? 
        (journalingCount / totalSlots).ceil() : 0;
    
    for (var i = 0; i < totalSlots; i++) {
      // Calculate how many entries for this slot
      final remainingEntries = journalingCount - (i * entriesPerSlot);
      final entryCount = remainingEntries > 0 
          ? min(entriesPerSlot, remainingEntries) 
          : 0;
      final hasEntry = entryCount > 0;
      
      // Get the label for this slot (matches order from labels list)
      final label = i < labels.length ? labels[i] : '';
      
      list.add(Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: hasEntry ? AppColors.peach.withOpacity(0.95) : AppColors.card,
              borderRadius: BorderRadius.circular(12),
              boxShadow: hasEntry
                  ? [
                      BoxShadow(
                        color: AppColors.textPrimary.withOpacity(0.06),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                hasEntry ? '$entryCount' : '',
                style: GoogleFonts.poppins(
                    fontSize: 14, 
                    fontWeight: FontWeight.w700,
                    color: hasEntry ? AppColors.textPrimary : Colors.transparent),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: AppColors.textPrimary.withOpacity(0.7),
              )),
        ],
      ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    String headline;
    switch (selectedRange) {
      case StatsRange.today:
        headline = journalingCount > 0
            ? t.youWroteToday
            : t.noEntryToday;
        break;
      case StatsRange.weekly:
        headline = t.daysLogged(journalingCount);
        break;
      case StatsRange.monthly:
        headline = t.entriesThisMonth(journalingCount);
        break;
      case StatsRange.yearly:
        headline = t.totalEntries(journalingCount);
        break;
    }

    return AnimatedContainer(
      duration: animationDuration,
      curve: animationCurve,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(t.journaling, 
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textPrimary.withOpacity(0.6)
            )
          ),
          const SizedBox(height: 8),
          Text(headline,
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Flexible(
            fit: FlexFit.loose,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _buildDayBubbles(t)
                    .expand((widget) => [widget, const SizedBox(width: 8)])
                    .toList()
                    ..removeLast(), // Remove trailing spacer
              ),
            ),
          ),
        ],
      ),
    );
  }
}