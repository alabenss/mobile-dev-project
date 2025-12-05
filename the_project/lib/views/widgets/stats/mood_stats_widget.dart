import 'dart:math';
import 'package:flutter/material.dart';
import 'package:the_project/l10n/app_localizations.dart';
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

  Widget _buildDonutChart() {
    if (moodData.isEmpty || moodData.every((m) => m == 0.0 || m == 0.5)) {
      return Center(
        child: Text(
          'No data',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
        ),
      );
    }
    
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
    
    return PieChart(
      PieChartData(
        centerSpaceRadius: 28,
        sectionsSpace: 2,
        sections: sections,
      ),
    );
  }

  Widget _buildLineChart() {
    if (moodData.isEmpty) {
      return Center(
        child: Text(
          'No mood data available',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
        ),
      );
    }
    
    final spots = List.generate(
      moodData.length, 
      (i) => FlSpot(i.toDouble(), moodData[i])
    );
    
    return LineChart(
      LineChartData(
        minY: 0.0,
        maxY: 1.0,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
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
    if (count == 0) {
      return const SizedBox.shrink();
    }
    
    final showCount = (count <= 7) ? count : (count <= 12 ? 7 : 8);
    final step = max(1, (count / showCount).floor());
    final chosen = <String>[];
    
    for (var i = 0; i < count; i += step) {
      chosen.add(labels[i]);
    }
    
    if (chosen.isEmpty) {
      chosen.addAll(labels.take(1));
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: chosen.map((d) => 
        Text(d, 
          style: GoogleFonts.poppins(
            fontSize: 10, 
            color: AppColors.textPrimary.withOpacity(0.7)
          )
        )
      ).toList(),
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
        Text(label, 
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textPrimary.withOpacity(0.8)
          )
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    String headline;
    if (moodData.isEmpty || moodData.every((m) => m == 0.0 || m == 0.5)) {
      headline = t?.moodOk ?? 'Okay';
    } else {
      final mean = (moodData.reduce((a, b) => a + b) / moodData.length);
      if (mean >= 0.75) {
        headline = t?.moodFeelingGreat ?? 'Feeling Great!';
      } else if (mean >= 0.6) {
        headline = t?.moodNice ?? 'Nice Mood';
      } else if (mean >= 0.45) {
        headline = t?.moodOk ?? 'Okay';
      } else {
        headline = t?.moodLow ?? 'Feeling Low';
      }
    }

    return AnimatedContainer(
      duration: animationDuration,
      curve: animationCurve,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t?.moodTracking ?? 'Mood Tracking', 
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textPrimary.withOpacity(0.6)
            )
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 120, 
                height: 120, 
                child: _buildDonutChart()
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(headline,
                      style: GoogleFonts.poppins(
                        fontSize: 20, 
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary
                      )
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _smallLegendDot(AppColors.mint, t?.calm ?? 'Calm'),
                        _smallLegendDot(AppColors.peach, t?.balanced ?? 'Balanced'),
                        _smallLegendDot(AppColors.coral, t?.low ?? 'Low'),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.card.withOpacity(0.3),
            ),
            child: _buildLineChart(),
          ),
          const SizedBox(height: 6),
          _buildChartLabels(),
        ],
      ),
    );
  }
}