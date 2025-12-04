import 'dart:math';
import 'package:flutter/material.dart';
import 'package:the_project/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_project/views/themes/style_simple/colors.dart';
import 'package:the_project/views/widgets/stats/range_selector_widget.dart';

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

  String _journalLabelForIndex(int i) {
    if (selectedRange == StatsRange.today) return 'Aujourd\'hui';
    if (selectedRange == StatsRange.weekly) {
      const days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      return days[i % 7];
    }
    if (selectedRange == StatsRange.monthly) return 'S${(i % 4) + 1}';
    return [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Août',
      'Sep',
      'Oct',
      'Nov',
      'Déc'
    ][i % 12];
  }

  List<Widget> _buildDayBubbles(AppLocalizations t) {
    final list = <Widget>[];
    final totalSlots = selectedRange == StatsRange.today
        ? 1
        : (selectedRange == StatsRange.weekly
            ? 7
            : (selectedRange == StatsRange.monthly ? 12 : 12));
    final rnd = Random(journalingCount + labels.length);
    final filledIndices = <int>{};
    for (var i = 0; i < min(totalSlots, journalingCount); i++) {
      filledIndices.add(rnd.nextInt(totalSlots));
    }
    for (var i = 0; i < totalSlots; i++) {
      final filled = filledIndices.contains(i);
      list.add(Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: filled ? AppColors.peach.withOpacity(0.95) : AppColors.card,
              borderRadius: BorderRadius.circular(12),
              boxShadow: filled
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
                filled ? '${rnd.nextInt(3) + 1}' : '',
                style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(_journalLabelForIndex(i),
              style: GoogleFonts.poppins(fontSize: 11)),
        ],
      ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    String headline;
    if (selectedRange == StatsRange.today) {
      headline = journalingCount > 0
          ? t.youWroteToday
          : t.noEntryToday;
    } else if (selectedRange == StatsRange.weekly) {
      headline = t.daysLogged(journalingCount);
    } else if (selectedRange == StatsRange.monthly) {
      headline = t.entriesThisMonth(journalingCount);
    } else {
      headline = t.totalEntries(journalingCount);
    }

    return AnimatedContainer(
      duration: animationDuration,
      curve: animationCurve,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.journaling, style: GoogleFonts.poppins(fontSize: 12)),
          const SizedBox(height: 8),
          Text(headline,
              style:
                  GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _buildDayBubbles(t),
          ),
        ],
      ),
    );
  }
}
