import 'dart:math';
import 'package:flutter/material.dart';
import 'package:the_project/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:the_project/views/themes/style_simple/colors.dart';
import 'range_selector_widget.dart';

class WaterStatsWidget extends StatelessWidget {
  final List<double> waterData;
  final List<String> labels;
  final StatsRange selectedRange;
  final Duration animationDuration;
  final Curve animationCurve;

  const WaterStatsWidget({
    super.key,
    required this.waterData,
    required this.labels,
    required this.selectedRange,
    this.animationDuration = const Duration(milliseconds: 420),
    this.animationCurve = Curves.easeInOutCubic,
  });

  Widget _buildChartLabels() {
    final count = labels.length;
    final showCount = (count <= 7) ? count : (count <= 12 ? 7 : 8);
    final step = max(1, (count / showCount).floor());
    final chosen = <String>[];
    for (var i = 0; i < count; i += step) {
      chosen.add(labels[i]);
    }
    if (chosen.isEmpty) chosen.addAll(labels.take(1));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:
          chosen.map((d) => Text(d, style: GoogleFonts.poppins(fontSize: 10))).toList(),
    );
  }

  Widget _buildBarChart() {
    final values = waterData;
    if (values.isEmpty) {
      return const SizedBox.shrink();
    }
    final maxY = values.reduce(max) * 1.1;
    return BarChart(
      BarChartData(
        maxY: maxY,
        barGroups: List.generate(values.length, (i) {
          final val = values[i];
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: val,
                width: (values.length <= 7 ? 18 : (values.length <= 12 ? 12 : 6))
                    .toDouble(),
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  colors: [
                    AppColors.sky.withOpacity(0.95),
                    AppColors.peach.withOpacity(0.95),
                  ],
                ),
              ),
            ],
          );
        }),
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: true),
        alignment: BarChartAlignment.spaceBetween,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    String headline;
    if (waterData.isEmpty) {
      headline = t?.glassesToday(0) ?? '0 glasses today';
    } else if (selectedRange == StatsRange.today) {
      headline = t?.glassesToday(waterData.first.toInt()) ?? '${waterData.first.toInt()} glasses today';
    } else if (selectedRange == StatsRange.weekly) {
      final avg =
          (waterData.reduce((a, b) => a + b) / waterData.length).round();
      headline = t?.avgPerDay(avg) ?? '$avg avg/day';
    } else if (selectedRange == StatsRange.monthly) {
      final avg =
          (waterData.reduce((a, b) => a + b) / waterData.length);
      headline = t?.monthlyAvg(avg.toStringAsFixed(1)) ?? '${avg.toStringAsFixed(1)} monthly avg';
    } else {
      final avg = waterData.reduce((a, b) => a + b) / waterData.length;
      headline = t?.yearlyAvg(avg.toStringAsFixed(1)) ?? '${avg.toStringAsFixed(1)} yearly avg';
    }

    return AnimatedContainer(
      duration: animationDuration,
      curve: animationCurve,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t?.waterStats ?? 'Water Stats', 
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textPrimary.withOpacity(0.6)
            )
          ),
          const SizedBox(height: 8),
          Text(headline,
              style:
                  GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: _buildBarChart(),
          ),
          const SizedBox(height: 8),
          _buildChartLabels(),
        ],
      ),
    );
  }
}