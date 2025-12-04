import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_project/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:the_project/views/themes/style_simple/app_background.dart';
import 'package:the_project/views/widgets/stats/range_selector_widget.dart';
import 'package:the_project/views/widgets/stats/stats_card_widget.dart';
import 'package:the_project/views/widgets/stats/water_stats_widget.dart';
import 'package:the_project/views/widgets/stats/mood_stats_widget.dart';
import 'package:the_project/views/widgets/stats/journaling_stats_widget.dart';
import 'package:the_project/views/widgets/stats/screen_time_widget.dart';
import 'package:the_project/views/themes/style_simple/colors.dart';

import 'package:the_project/database/repo/stats_repo.dart';
import 'package:the_project/logic/statistics/stats_cubit.dart';
import 'package:the_project/logic/statistics/stats_state.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  static const Duration animDur = Duration(milliseconds: 420);
  static const Curve animCurve = Curves.easeInOutCubic;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => StatsCubit(repo: StatsRepo())..init(),
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Column(
                children: [
                  // Top row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t.statistics,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  /// 🔹 The *whole* stats content is now inside Expanded
                  Expanded(
                    child: BlocBuilder<StatsCubit, StatsState>(
                      builder: (context, state) {
                        final selectedRange = state.range;

                        return Column(
                          children: [
                            RangeSelectorWidget(
                              selectedRange: selectedRange,
                              onRangeSelected: (r) => context
                                  .read<StatsCubit>()
                                  .loadForRange(r),
                              animationDuration: animDur,
                              animationCurve: animCurve,
                            ),
                            const SizedBox(height: 12),

                            /// 🔹 Only this Expanded remains
                            Expanded(
                              child: _buildBodyForState(context, state),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyForState(BuildContext context, StatsState state) {
    final t = AppLocalizations.of(context)!;

    if (state is StatsLoading || state is StatsInitial) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is StatsError) {
      return Center(
        child: Text(
          'Erreur : ${state.message}',
          style: GoogleFonts.poppins(color: Colors.red),
        ),
      );
    } else if (state is StatsLoaded) {
      return AnimatedSwitcher(
        duration: animDur,
        switchInCurve: animCurve,
        switchOutCurve: animCurve,
        transitionBuilder: (child, animation) {
          final offsetAnim = Tween<Offset>(
                  begin: const Offset(0, 0.07), end: Offset.zero)
              .animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offsetAnim, child: child),
          );
        },
        child: _buildScrollableCards(
          key: ValueKey(state.range),
          state: state,
          t: t,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildScrollableCards({
    required Key key,
    required StatsLoaded state,
    required AppLocalizations t,
  }) {
    return SingleChildScrollView(
      key: key,
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          StatsCardWidget(
            padding: const EdgeInsets.all(14),
            child: WaterStatsWidget(
              waterData: state.waterData,
              labels: state.labels,
              selectedRange: state.range,
              animationDuration: animDur,
              animationCurve: animCurve,
            ),
          ),
          const SizedBox(height: 12),
          StatsCardWidget(
            padding: const EdgeInsets.all(14),
            child: MoodStatsWidget(
              moodData: state.moodData,
              labels: state.labels,
              selectedRange: state.range,
              animationDuration: animDur,
              animationCurve: animCurve,
            ),
          ),
          const SizedBox(height: 12),
          StatsCardWidget(
            padding: const EdgeInsets.all(14),
            child: JournalingStatsWidget(
              journalingCount: state.journalingCount,
              selectedRange: state.range,
              labels: state.labels,
              animationDuration: animDur,
              animationCurve: animCurve,
            ),
          ),
          const SizedBox(height: 12),
          StatsCardWidget(
            padding: const EdgeInsets.all(14),
            child: ScreenTimeWidget(
              screenTime: state.screenTime,
              animationDuration: animDur,
              animationCurve: animCurve,
            ),
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}
