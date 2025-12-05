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
                        t.statistics ?? 'Statistics',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      BlocBuilder<StatsCubit, StatsState>(
                        builder: (context, state) {
                          return IconButton(
                            icon: Icon(
                              Icons.refresh,
                              color: AppColors.accentPurple,
                            ),
                            onPressed: () {
                              context.read<StatsCubit>().refresh();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Refreshing data...'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
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
            CircularProgressIndicator(
              color: AppColors.accentPurple,
            ),
            SizedBox(height: 16),
            Text(
              'Loading statistics...',
              style: GoogleFonts.poppins(
                color: AppColors.textPrimary.withOpacity(0.6)
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
            Icon(
              Icons.error_outline,
              size: 50,
              color: AppColors.coral,
            ),
            SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              state.message,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textPrimary.withOpacity(0.6)
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<StatsCubit>().refresh(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Try Again',
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

    // Initial state
    return Center(
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
    final hasData = state.waterData.isNotEmpty || 
                    state.moodData.isNotEmpty || 
                    state.journalingCount > 0;
    
    return SingleChildScrollView(
      key: key,
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          if (!hasData) ...[
            _buildEmptyState(t),
            SizedBox(height: 20),
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
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 50,
            color: AppColors.accentPurple.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            'No Data Yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start using the app to see your statistics here',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textPrimary.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: AppColors.mint, size: 16),
              SizedBox(width: 8),
              Text('Track your mood daily'),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: AppColors.mint, size: 16),
              SizedBox(width: 8),
              Text('Log your water intake'),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: AppColors.mint, size: 16),
              SizedBox(width: 8),
              Text('Write journal entries'),
            ],
          ),
        ],
      ),
    );
  }
}