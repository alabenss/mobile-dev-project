import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:the_project/views/themes/style_simple/colors.dart';
import 'range_selector_widget.dart';

class MoodStatsWidget extends StatelessWidget {
  final List<double> moodData;
  final List<String> labels;
  final StatsRange selectedRange;
  final Duration animationDuration;
  final Curve animationCurve;

  const MoodStatsWidget({
    super.key,
    required this.moodData,
    required this.labels,
    required this.selectedRange,
    this.animationDuration = const Duration(milliseconds: 420),
    this.animationCurve = Curves.easeInOutCubic,
  });

  String get _headline {
    final mean = (moodData.reduce((a, b) => a + b) / moodData.length);
    if (mean >= 0.75) return 'Feeling great';
    if (mean >= 0.6) return 'Nice';
    if (mean >= 0.45) return 'Okay';
    return 'Low';
  }

  Widget _buildDonutChart() {
    final avg = (moodData.reduce((a, b) => a + b) / moodData.length);
    final high = ((avg - 0.45) / 0.55).clamp(0.0, 1.0);
    final mid = (1 - high) * 0.6;
    final low = (1 - high - mid).clamp(0.0, 1.0);
    final sections = [
      PieChartSectionData(
        value: (high * 60) + 10,
        color: AppColors.mint,
        radius: 28,
        showTitle: false,
      ),
      PieChartSectionData(
        value: (mid * 30) + 5,
        color: AppColors.peach,
        radius: 22,
        showTitle: false,
      ),
      PieChartSectionData(
        value: (low * 20) + 2,
        color: AppColors.coral,
        radius: 18,
        showTitle: false,
      ),
    ];
    return PieChart(PieChartData(
      centerSpaceRadius: 28,
      sectionsSpace: 2,
      sections: sections,
    ));
  }

  Widget _buildLineChart() {
    final spots = List.generate(moodData.length, (i) => FlSpot(i.toDouble(), moodData[i]));
    return LineChart(
      LineChartData(
        minY: 0.0,
        maxY: 1.0,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false), // Removed const
        titlesData: const FlTitlesData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            preventCurveOverShooting: true,
            dotData: const FlDotData(show: false),
            color: AppColors.accentPurple,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(colors: [
                AppColors.accentPurple.withOpacity(0.08),
                AppColors.accentPurple.withOpacity(0.0),
              ]),
            ),
            barWidth: 3,
          )
        ],
        lineTouchData: const LineTouchData(enabled: true),
      ),
    );
  }

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
      children: chosen.map((d) => Text(d, style: GoogleFonts.poppins(fontSize: 10))).toList(),
    );
  }

  Widget _smallLegendDot(Color c, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.poppins(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: animationDuration,
      curve: animationCurve,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Mood tracking', style: GoogleFonts.poppins(fontSize: 12)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 120, height: 120, child: _buildDonutChart()),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_headline,
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Row(children: [
                    _smallLegendDot(AppColors.mint, 'Calm'),
                    const SizedBox(width: 8),
                    _smallLegendDot(AppColors.peach, 'Balanced'),
                    const SizedBox(width: 8),
                    _smallLegendDot(AppColors.coral, 'Low'),
                  ]),
                ],
              )
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(height: 110, child: _buildLineChart()),
          const SizedBox(height: 6),
          _buildChartLabels(),
        ],
      ),
    );
  }
}