// stats_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:the_project/views/widgets/app_background.dart';
import '../../themes/style_simple/colors.dart';
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

enum StatsRange { today, weekly, monthly, yearly }

class _StatsScreenState extends State<StatsScreen> with TickerProviderStateMixin {
  StatsRange selectedRange = StatsRange.weekly;

  // theme colors

  // Data model for the four sections (kept simple for demo)
  late List<double> waterData; // glasses per period unit
  late List<double> moodData; // 0..1 per period unit
  late int journalingCount; // number of entries in the period
  late Map<String, double> screenTime; // hours per category
  late List<String> labels; // x-axis labels for the current dataset

  final Duration animDur = const Duration(milliseconds: 420);
  final Curve animCurve = Curves.easeInOutCubic;

  @override
  void initState() {
    super.initState();
    _generateDataFor(selectedRange);
  }

  void _generateDataFor(StatsRange r) {
    final rnd = Random(r.hashCode ^ DateTime.now().day);
    if (r == StatsRange.today) {
      // Today = single-day snapshot
      waterData = [ (6 + rnd.nextInt(6)).toDouble() ]; // 6-11 glasses
      moodData = [ (0.5 + rnd.nextDouble() * 0.45) ]; // 0.5 - 0.95
      journalingCount = rnd.nextBool() ? 1 : 0;
      screenTime = {
        'social': double.parse((0.2 + rnd.nextDouble() * 1.0).toStringAsFixed(1)),
        'entertainment': double.parse((0.5 + rnd.nextDouble() * 2.0).toStringAsFixed(1)),
        'productivity': double.parse((0.5 + rnd.nextDouble() * 3.0).toStringAsFixed(1)),
      };
      labels = ['Today'];
    } else if (r == StatsRange.weekly) {
      // Weekly = 7 days
      waterData = List.generate(7, (_) => 6 + rnd.nextInt(6).toDouble());
      moodData = List.generate(7, (_) => double.parse((0.45 + rnd.nextDouble()*0.5).toStringAsFixed(2)));
      journalingCount = 2 + rnd.nextInt(5); // 2..6 journaling days
      screenTime = {
        'social': double.parse((1.0 + rnd.nextDouble() * 1.5).toStringAsFixed(1)),
        'entertainment': double.parse((1.5 + rnd.nextDouble() * 2.5).toStringAsFixed(1)),
        'productivity': double.parse((2.0 + rnd.nextDouble() * 2.5).toStringAsFixed(1)),
      };
      labels = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    } else if (r == StatsRange.monthly) {
      // Monthly = 30 days (we'll show compressed chart)
      waterData = List.generate(30, (i) {
        // some weekly rhythm + randomness
        final base = 7 + 2 * sin(i / 3) + rnd.nextDouble() * 2;
        return double.parse(base.clamp(2, 12).toStringAsFixed(1));
      });
      moodData = List.generate(30, (i) => double.parse((0.45 + rnd.nextDouble()*0.5).toStringAsFixed(2)));
      journalingCount = 6 + rnd.nextInt(18); // 6..24 entries
      screenTime = {
        'social': double.parse((1.0 + rnd.nextDouble() * 1.8).toStringAsFixed(1)),
        'entertainment': double.parse((1.8 + rnd.nextDouble() * 2.4).toStringAsFixed(1)),
        'productivity': double.parse((1.5 + rnd.nextDouble() * 3.0).toStringAsFixed(1)),
      };
      labels = List.generate(30, (i) => '${i+1}');
    } else {
      // Yearly = 12 months summary
      waterData = List.generate(12, (i) => double.parse((6 + 2 * (0.6 + 0.4 * sin(i/2)) + rnd.nextDouble()*1.8).toStringAsFixed(1)));
      moodData = List.generate(12, (i) => double.parse((0.5 + rnd.nextDouble()*0.4).toStringAsFixed(2)));
      journalingCount = 20 + rnd.nextInt(120); // many entries across year
      screenTime = {
        'social': double.parse((0.7 + rnd.nextDouble() * 1.6).toStringAsFixed(1)),
        'entertainment': double.parse((1.2 + rnd.nextDouble() * 2.8).toStringAsFixed(1)),
        'productivity': double.parse((1.8 + rnd.nextDouble() * 3.5).toStringAsFixed(1)),
      };
      labels = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    }
    
    setState(() {});
  }

  void _onRangeTap(StatsRange r) {
    if (selectedRange == r) return;
    setState(() => selectedRange = r);
    // regenarate with slight animation delay to feel responsive
    Future.delayed(const Duration(milliseconds: 70), () => _generateDataFor(r));
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double horizontalPadding = 16;
    return Scaffold(
     body: AppBackground(
      child: SafeArea(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 14),
         
          child: Column(
            children: [
              // Top row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Statistics',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      )),
                  
                ],
              ),
              const SizedBox(height: 12),

              // Segmented control
              _buildSegmentedControl(),

              const SizedBox(height: 12),

              // Animated content
              Expanded(
                child: AnimatedSwitcher(
                  duration: animDur,
                  switchInCurve: animCurve,
                  switchOutCurve: animCurve,
                  transitionBuilder: (child, animation) {
                    final offsetAnim = Tween<Offset>(begin: const Offset(0, 0.07), end: Offset.zero).animate(animation);
                    return FadeTransition(opacity: animation, child: SlideTransition(position: offsetAnim, child: child));
                  },
                  child: _buildScrollableCards(key: ValueKey(selectedRange)),
                ),
              ),
            ],
          ),
        ),
      ),
    )
    );
  }

  // Build the scroll content (kept as single widget for AnimatedSwitcher child)
  Widget _buildScrollableCards({required Key key}) {
    return SingleChildScrollView(
      key: key,
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildCard(
            child: AnimatedContainer(
              duration: animDur,
              curve: animCurve,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Water statistics', style: GoogleFonts.poppins(fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(_waterHeadline(), style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: _waterBarChart(),
                  ),
                  const SizedBox(height: 8),
                  _buildChartLabelsForCurrentRange(),
                ],
              ),
            ),
            padding: const EdgeInsets.all(14),
          ),
          const SizedBox(height: 12),

          _buildCard(
            child: AnimatedContainer(
              duration: animDur,
              curve: animCurve,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mood tracking', style: GoogleFonts.poppins(fontSize: 12)),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 120, height: 120, child: _moodDonut()),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_moodHeadline(), style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Row(children: [
                            _smallLegendDot(AppColors. mint, 'Calm'),
                            const SizedBox(width: 8),
                            _smallLegendDot(AppColors.peach, 'Balanced'),
                            const SizedBox(width: 8),
                            _smallLegendDot(AppColors. coral, 'Low'),
                          ]),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(height: 110, child: _moodLineChart()),
                  const SizedBox(height: 6),
                  _buildChartLabelsForCurrentRange(),
                ],
              ),
            ),
            padding: const EdgeInsets.all(14),
          ),

          const SizedBox(height: 12),

          _buildCard(
            child: AnimatedContainer(
              duration: animDur,
              curve: animCurve,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Journaling', style: GoogleFonts.poppins(fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(_journalingHeadline(), style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _buildJournalDayBubbles(),
                  )
                ],
              ),
            ),
            padding: const EdgeInsets.all(14),
          ),

          const SizedBox(height: 12),

          _buildCard(
            child: AnimatedContainer(
              duration: animDur,
              curve: animCurve,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Screen time', style: GoogleFonts.poppins(fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(_screenTimeHeadline(), style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  for (var e in screenTime.entries) ...[
                    Text(capitalize(e.key), style: GoogleFonts.poppins(fontSize: 12)),
                    const SizedBox(height: 6),
                    Stack(
                      children: [
                        Container(
                          height: 12,
                          decoration: BoxDecoration(color: AppColors.card.withOpacity(0.7), borderRadius: BorderRadius.circular(12)),
                        ),
                        LayoutBuilder(builder: (context, cons) {
                          final maxWidth = cons.maxWidth;
                          final percent = (e.value / max(1.0, (screenTime.values.reduce(max)))) .clamp(0.05, 1.0);
                          return Container(
                            height: 12,
                            width: maxWidth * percent,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [AppColors. coral.withOpacity(0.95), AppColors.peach.withOpacity(0.95)]),
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
            ),
            padding: const EdgeInsets.all(14),
          ),

          const SizedBox(height: 90),
        ],
      ),
    );
  }

  // Helpers for headlines
  String _waterHeadline() {
    if (selectedRange == StatsRange.today) {
      return '${waterData.first.toInt()} glasses today';
    } else if (selectedRange == StatsRange.weekly) {
      final avg = (waterData.reduce((a,b) => a+b)/waterData.length).round();
      return 'Avg. $avg glasses / day';
    } else if (selectedRange == StatsRange.monthly) {
      final avg = (waterData.reduce((a,b) => a+b)/waterData.length);
      return 'Monthly avg ${avg.toStringAsFixed(1)} glasses';
    } else {
      final avg = (waterData.reduce((a,b) => a+b)/waterData.length).toStringAsFixed(1);
      return 'Yearly avg $avg glasses';
    }
  }

  String _moodHeadline() {
    final mean = (moodData.reduce((a,b) => a+b)/moodData.length);
    if (mean >= 0.75) return 'Feeling great';
    if (mean >= 0.6) return 'Nice';
    if (mean >= 0.45) return 'Okay';
    return 'Low';
  }

  String _journalingHeadline() {
    if (selectedRange == StatsRange.today) {
      return journalingCount > 0 ? 'You wrote today' : 'No entry today';
    } else if (selectedRange == StatsRange.weekly) {
      return '$journalingCount days logged';
    } else if (selectedRange == StatsRange.monthly) {
      return '$journalingCount entries this month';
    } else {
      return '$journalingCount total entries';
    }
  }

  String _screenTimeHeadline() {
    final total = screenTime.values.reduce((a,b) => a+b);
    return '${total.toStringAsFixed(1)} h/day';
  }

  // Chart / UI building

  Widget _waterBarChart() {
    final values = waterData;
    final maxY = max(12.0, (values.reduce(max) * 1.1));
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
                width: (values.length <= 7 ? 18 : (values.length <= 12 ? 12 : 6)),
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(colors: [AppColors. sky.withOpacity(0.95), AppColors.peach.withOpacity(0.95)]),
              ),
            ],
          );
        }),
        titlesData: FlTitlesData(show: false),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: true),
        alignment: BarChartAlignment.spaceBetween,
      ),
    );
  }

  Widget _moodDonut() {
    // split mood into high/medium/low proportions
    final avg = (moodData.reduce((a,b)=>a+b)/moodData.length);
    final high = ((avg - 0.45) / 0.55).clamp(0.0, 1.0); // normalized high portion
    final mid = (1 - high) * 0.6;
    final low = (1 - high - mid).clamp(0.0, 1.0);
    final sections = [
      PieChartSectionData(value: (high*60)+10, color: AppColors. mint, radius: 28, showTitle: false),
      PieChartSectionData(value: (mid*30)+5, color: AppColors.peach, radius: 22, showTitle: false),
      PieChartSectionData(value: (low*20)+2, color: AppColors. coral, radius: 18, showTitle: false),
    ];
    return PieChart(PieChartData(centerSpaceRadius: 28, sectionsSpace: 2, sections: sections));
  }

  Widget _moodLineChart() {
    final spots = List.generate(moodData.length, (i) => FlSpot(i.toDouble(), moodData[i]));
    return LineChart(LineChartData(
      minY: 0.0,
      maxY: 1.0,
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          preventCurveOverShooting: true,
          dotData: FlDotData(show: false),
          color: AppColors.accentPurple,
          belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [
            AppColors.accentPurple.withOpacity(0.08),
            AppColors.accentPurple.withOpacity(0.0),
          ])),
          barWidth: 3,
        )
      ],
      lineTouchData: LineTouchData(enabled: true),
    ));
  }

  Widget _buildCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.card.withOpacity(0.98), AppColors.card.withOpacity(0.92)]),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: AppColors.textPrimary.withOpacity(0.06), blurRadius: 8, offset: const Offset(0,6))],
      ),
      padding: padding ?? const EdgeInsets.all(12),
      child: child,
    );
  }

  Widget _buildSegmentedControl() {
    final tabs = {
      StatsRange.today: 'today',
      StatsRange.weekly: 'weekly',
      StatsRange.monthly: 'monthly',
      StatsRange.yearly: 'yearly'
    };
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.card.withOpacity(0.35), borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: tabs.entries.map((entry) {
          final isSelected = entry.key == selectedRange;
          return Expanded(
            child: GestureDetector(
              onTap: () => _onRangeTap(entry.key),
              child: AnimatedContainer(
                duration: animDur,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.card : AppColors.transparent,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: isSelected ? [BoxShadow(color: AppColors.textPrimary.withOpacity(0.08), blurRadius: 6, offset: const Offset(0,3))] : null,
                ),
                child: Center(child: Text(entry.value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: AppColors.textPrimary))),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartLabelsForCurrentRange() {
    // For long ranges we show fewer labels to avoid clutter
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
        Container(width: 12, height: 12, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.poppins(fontSize: 12))
      ],
    );
  }

  List<Widget> _buildJournalDayBubbles() {
    // show a stylized set of small bubbles representing logged days.
    final list = <Widget>[];
    final totalSlots = selectedRange == StatsRange.today ? 1 : (selectedRange == StatsRange.weekly ? 7 : (selectedRange == StatsRange.monthly ? 12 : 12));
    final rnd = Random(journalingCount + labels.length);
    final filledIndices = <int>{};
    for (var i=0; i<min(totalSlots, journalingCount); i++) {
      filledIndices.add(rnd.nextInt(totalSlots));
    }
    for (var i=0; i<totalSlots; i++) {
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
              boxShadow: filled ? [BoxShadow(color: AppColors.textPrimary.withOpacity(0.06), blurRadius: 6, offset: const Offset(0,4))] : null,
            ),
            child: Center(child: Text(filled ? '${rnd.nextInt(3)+1}' : '', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700))),
          ),
          const SizedBox(height: 6),
          Text(_journalLabelForIndex(i), style: GoogleFonts.poppins(fontSize: 11))
        ],
      ));
    }
    return list;
  }

  String _journalLabelForIndex(int i) {
    if (selectedRange == StatsRange.today) return 'Today';
    if (selectedRange == StatsRange.weekly) return ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][i % 7];
    if (selectedRange == StatsRange.monthly) return 'W${(i%4)+1}';
    return ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][i % 12];
  }

  String capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}