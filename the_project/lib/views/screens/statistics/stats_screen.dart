import 'dart:async';
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
import 'package:the_project/database/db_helper.dart';

class StatsScreen extends StatefulWidget {
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  static const Duration animDur = Duration(milliseconds: 420);
  static const Curve animCurve = Curves.easeInOutCubic;

  @override
  void initState() {
    super.initState();
    // Debug: Print all tables when stats screen opens
    _debugPrintTables();
  }

  Future<void> _debugPrintTables() async {
    print('\n🔍 Stats Screen Opened - Printing Database Tables...');
    await DBHelper.debugPrintAllTables();
  }

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
                      BlocBuilder<StatsCubit, StatsState>(
                        builder: (context, state) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Debug button
                              IconButton(
                                icon: Icon(
                                  Icons.bug_report,
                                  color: AppColors.coral,
                                ),
                                onPressed: () async {
                                  await DBHelper.debugPrintAllTables();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Database tables printed to console'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                              // Refresh button
                              IconButton(
                                icon: Icon(
                                  Icons.refresh,
                                  color: AppColors.accentPurple,
                                ),
                                onPressed: () {
                                  context.read<StatsCubit>().refresh();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(t.statsRefreshingData),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  /// Main stats content
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

                            /// Scrollable content area
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

    if (state is StatsLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppColors.accentPurple,
            ),
            const SizedBox(height: 16),
            Text(
              t.statsLoading,
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    } else if (state is StatsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 50,
              color: AppColors.coral,
            ),
            const SizedBox(height: 16),
            Text(
              t.statsErrorTitle,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              state.message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textPrimary.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<StatsCubit>().refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                t.commonTryAgain,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (state is StatsLoaded) {
      return AnimatedSwitcher(
        duration: animDur,
        switchInCurve: animCurve,
        switchOutCurve: animCurve,
        transitionBuilder: (child, animation) {
          final offsetAnim = Tween<Offset>(
            begin: const Offset(0, 0.07),
            end: Offset.zero,
          ).animate(animation);
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

    // Initial state
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.accentPurple,
      ),
    );
  }

  Widget _buildScrollableCards({
    required Key key,
    required StatsLoaded state,
    required AppLocalizations t,
  }) {
    final hasData = state.waterData.any((w) => w > 0) ||
        state.moodData.any((m) => m != 0.5) ||
        state.journalingCount > 0;

    return SingleChildScrollView(
      key: key,
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          if (!hasData) ...[
            _buildEmptyState(t),
            const SizedBox(height: 20),
          ],

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

  Widget _buildEmptyState(AppLocalizations t) {
    return StatsCardWidget(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 50,
            color: AppColors.accentPurple.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            t.statsEmptyTitle,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.statsEmptySubtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textPrimary.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: AppColors.mint, size: 16),
              const SizedBox(width: 8),
              Text(t.statsEmptyTrackMood),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: AppColors.mint, size: 16),
              const SizedBox(width: 8),
              Text(t.statsEmptyLogWater),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: AppColors.mint, size: 16),
              const SizedBox(width: 8),
              Text(t.statsEmptyWriteJournal),
            ],
          ),
        ],
      ),
    );
  }
}