// stats_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:the_project/views/themes/style_simple/app_background.dart';
import 'package:the_project/views/widgets/stats/range_selector_widget.dart';
import 'package:the_project/views/widgets/stats/stats_card_widget.dart';
import 'package:the_project/views/widgets/stats/water_stats_widget.dart';
import 'package:the_project/views/widgets/stats/mood_stats_widget.dart';
import 'package:the_project/views/widgets/stats/journaling_stats_widget.dart';
import 'package:the_project/views/widgets/stats/screen_time_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_project/views/themes/style_simple/colors.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with TickerProviderStateMixin {
  StatsRange selectedRange = StatsRange.weekly;
  late List<double> waterData;
  late List<double> moodData;
  late int journalingCount;
  late Map<String, double> screenTime;
  late List<String> labels;

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
      waterData = [(6 + rnd.nextInt(6)).toDouble()];
      moodData = [(0.5 + rnd.nextDouble() * 0.45)];
      journalingCount = rnd.nextBool() ? 1 : 0;
      screenTime = {
        'social': double.parse((0.2 + rnd.nextDouble() * 1.0).toStringAsFixed(1)),
        'entertainment': double.parse((0.5 + rnd.nextDouble() * 2.0).toStringAsFixed(1)),
        'productivity': double.parse((0.5 + rnd.nextDouble() * 3.0).toStringAsFixed(1)),
      };
      labels = ['Today'];
    } else if (r == StatsRange.weekly) {
      waterData = List.generate(7, (_) => 6 + rnd.nextInt(6).toDouble());
      moodData = List.generate(7, (_) => double.parse((0.45 + rnd.nextDouble() * 0.5).toStringAsFixed(2)));
      journalingCount = 2 + rnd.nextInt(5);
      screenTime = {
        'social': double.parse((1.0 + rnd.nextDouble() * 1.5).toStringAsFixed(1)),
        'entertainment': double.parse((1.5 + rnd.nextDouble() * 2.5).toStringAsFixed(1)),
        'productivity': double.parse((2.0 + rnd.nextDouble() * 2.5).toStringAsFixed(1)),
      };
      labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    } else if (r == StatsRange.monthly) {
      waterData = List.generate(30, (i) {
        final base = 7 + 2 * sin(i / 3) + rnd.nextDouble() * 2;
        return double.parse(base.clamp(2, 12).toStringAsFixed(1));
      });
      moodData = List.generate(30, (i) => double.parse((0.45 + rnd.nextDouble() * 0.5).toStringAsFixed(2)));
      journalingCount = 6 + rnd.nextInt(18);
      screenTime = {
        'social': double.parse((1.0 + rnd.nextDouble() * 1.8).toStringAsFixed(1)),
        'entertainment': double.parse((1.8 + rnd.nextDouble() * 2.4).toStringAsFixed(1)),
        'productivity': double.parse((1.5 + rnd.nextDouble() * 3.0).toStringAsFixed(1)),
      };
      labels = List.generate(30, (i) => '${i + 1}');
    } else {
      waterData = List.generate(12, (i) => double.parse((6 + 2 * (0.6 + 0.4 * sin(i / 2)) + rnd.nextDouble() * 1.8).toStringAsFixed(1)));
      moodData = List.generate(12, (i) => double.parse((0.5 + rnd.nextDouble() * 0.4).toStringAsFixed(2)));
      journalingCount = 20 + rnd.nextInt(120);
      screenTime = {
        'social': double.parse((0.7 + rnd.nextDouble() * 1.6).toStringAsFixed(1)),
        'entertainment': double.parse((1.2 + rnd.nextDouble() * 2.8).toStringAsFixed(1)),
        'productivity': double.parse((1.8 + rnd.nextDouble() * 3.5).toStringAsFixed(1)),
      };
      labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    }

    setState(() {});
  }

  void _onRangeTap(StatsRange r) {
    if (selectedRange == r) return;
    setState(() => selectedRange = r);
    Future.delayed(const Duration(milliseconds: 70), () => _generateDataFor(r));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                RangeSelectorWidget(
                  selectedRange: selectedRange,
                  onRangeSelected: _onRangeTap,
                  animationDuration: animDur,
                  animationCurve: animCurve,
                ),

                const SizedBox(height: 12),

                // Animated content
                Expanded(
                  child: AnimatedSwitcher(
                    duration: animDur,
                    switchInCurve: animCurve,
                    switchOutCurve: animCurve,
                    transitionBuilder: (child, animation) {
                      final offsetAnim = Tween<Offset>(begin: const Offset(0, 0.07), end: Offset.zero).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: offsetAnim, child: child),
                      );
                    },
                    child: _buildScrollableCards(key: ValueKey(selectedRange)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableCards({required Key key}) {
    return SingleChildScrollView(
      key: key,
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          StatsCardWidget(
            child: WaterStatsWidget(
              waterData: waterData,
              labels: labels,
              selectedRange: selectedRange,
              animationDuration: animDur,
              animationCurve: animCurve,
            ),
            padding: const EdgeInsets.all(14),
          ),
          const SizedBox(height: 12),

          StatsCardWidget(
            child: MoodStatsWidget(
              moodData: moodData,
              labels: labels,
              selectedRange: selectedRange,
              animationDuration: animDur,
              animationCurve: animCurve,
            ),
            padding: const EdgeInsets.all(14),
          ),

          const SizedBox(height: 12),

          StatsCardWidget(
            child: JournalingStatsWidget(
              journalingCount: journalingCount,
              selectedRange: selectedRange,
              labels: labels,
              animationDuration: animDur,
              animationCurve: animCurve,
            ),
            padding: const EdgeInsets.all(14),
          ),

          const SizedBox(height: 12),

          StatsCardWidget(
            child: ScreenTimeWidget(
              screenTime: screenTime,
              animationDuration: animDur,
              animationCurve: animCurve,
            ),
            padding: const EdgeInsets.all(14),
          ),

          const SizedBox(height: 90),
        ],
      ),
    );
  }
}