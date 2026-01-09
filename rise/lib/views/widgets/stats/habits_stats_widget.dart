// lib/views/widgets/stats/habits_stats_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:the_project/views/themes/style_simple/colors.dart';
import 'package:the_project/views/widgets/stats/range_selector_widget.dart';
import 'package:the_project/l10n/app_localizations.dart';

class HabitsStatsWidget extends StatefulWidget {
  final int totalHabits;
  final int completedHabits;
  final double completionRate;
  final int currentStreak;
  final int bestStreak;
  final List<double> habitCompletionData;
  final int tasksConvertedToHabits;
  final StatsRange selectedRange;
  final List<String> labels;
  final Duration animationDuration;
  final Curve animationCurve;

  const HabitsStatsWidget({
    super.key,
    required this.totalHabits,
    required this.completedHabits,
    required this.completionRate,
    required this.currentStreak,
    required this.bestStreak,
    required this.habitCompletionData,
    required this.tasksConvertedToHabits,
    required this.selectedRange,
    required this.labels,
    this.animationDuration = const Duration(milliseconds: 420),
    this.animationCurve = Curves.easeInOutCubic,
  });

  @override
  State<HabitsStatsWidget> createState() => _HabitsStatsWidgetState();
}

class _HabitsStatsWidgetState extends State<HabitsStatsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: widget.animationCurve),
    );
    _animController.forward();
  }

  @override
  void didUpdateWidget(HabitsStatsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedRange != widget.selectedRange) {
      _animController.reset();
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.task_alt,
                  color: AppColors.accentPurple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                t.statistics, // Localized: 'Statistics'
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Summary metrics
          _buildSummaryMetrics(t),
          const SizedBox(height: 16),

          // Completion rate chart
          if (widget.habitCompletionData.isNotEmpty) ...[
            _buildCompletionChart(t),
            const SizedBox(height: 16),
          ],

          // Streak info
          _buildStreakInfo(t),
          
          // Tasks converted badge (if any)
          if (widget.tasksConvertedToHabits > 0) ...[
            const SizedBox(height: 12),
            _buildTasksConvertedBadge(t),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryMetrics(AppLocalizations t) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            label: t.statistics, // Localized: 'Statistics'
            value: widget.totalHabits.toString(),
            icon: Icons.checklist,
            color: AppColors.accentPurple,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            label: t.completed, // Localized: 'Completed'
            value: widget.completedHabits.toString(),
            icon: Icons.check_circle,
            color: AppColors.mint,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            label: t.monthly, // Localized: 'Monthly' (used for rate)
            value: '${widget.completionRate.toStringAsFixed(0)}%',
            icon: Icons.trending_up,
            color: AppColors.coral,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textPrimary.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionChart(AppLocalizations t) {
    final hasData = widget.habitCompletionData.any((d) => d > 0);
    
    if (!hasData) {
      return Container(
        height: 140,
        alignment: Alignment.center,
        child: Text(
          t.noData, // Localized: 'No data'
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppColors.textPrimary.withOpacity(0.4),
          ),
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.textPrimary.withOpacity(0.05),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                interval: 25,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}%',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppColors.textPrimary.withOpacity(0.5),
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= widget.labels.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      widget.labels[index],
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.textPrimary.withOpacity(0.5),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (widget.habitCompletionData.length - 1).toDouble(),
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: widget.habitCompletionData.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value);
              }).toList(),
              isCurved: true,
              color: AppColors.accentPurple,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.accentPurple,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.accentPurple.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakInfo(AppLocalizations t) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.mint.withOpacity(0.15),
                  AppColors.mint.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.mint.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: AppColors.mint,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.monthly, // Localized: 'Monthly' (used for Current Streak)
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textPrimary.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        t.daysLogged(widget.currentStreak), // Localized: '{count} days logged'
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.coral.withOpacity(0.15),
                  AppColors.coral.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.coral.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: AppColors.coral,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.yearly, // Localized: 'Yearly' (used for Best Streak)
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textPrimary.withOpacity(0.6),
                        ),
                      ),
                      Text(
                        t.daysLogged(widget.bestStreak), // Localized: '{count} days logged'
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTasksConvertedBadge(AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentPurple.withOpacity(0.15),
            AppColors.accentPurple.withOpacity(0.05),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accentPurple.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome,
            color: AppColors.accentPurple,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                children: [
                  TextSpan(
                    text: '${widget.tasksConvertedToHabits} ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: widget.tasksConvertedToHabits == 1
                        ? t.habitCompleted('task') // Localized: '{habit} completed!'
                        : t.habitCompleted('tasks'), // Localized: '{habit} completed!'
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}