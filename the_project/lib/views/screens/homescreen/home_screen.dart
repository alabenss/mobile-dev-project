import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_project/l10n/app_localizations.dart';

import '../../../commons/config.dart';
import '../../../commons/constants.dart';
import '../../themes/style_simple/colors.dart';
import '../articles/plant_article.dart';
import '../articles/sport_article.dart';
import '../../widgets/journal/mood_card.dart';

// new, extracted widgets
import '../../widgets/home/image_quote_card.dart';
import '../../widgets/home/section_card.dart';
import '../../widgets/home/water_card.dart';
import '../../widgets/home/detox_card.dart';
import '../../widgets/home/habit_tile.dart';
import '../../widgets/home/explore_card.dart';

import '../../../logic/home/home_cubit.dart';
import '../../../logic/home/home_state.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../utils/habit_localization.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onViewAllHabits;
  const HomeScreen({super.key, this.onViewAllHabits});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Access widget properties through widget.propertyName
  VoidCallback? get onViewAllHabits => widget.onViewAllHabits;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;

      if (authState.isAuthenticated && authState.user != null) {
        context.read<HomeCubit>().loadInitial(
          userName: authState.user!.name,
        );
      }
    });
  }

  // currently unused, left as-is
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final homeCubit = context.read<HomeCubit>();

        // Limit to first 2 daily habits only
        final habitsToShow = state.dailyHabits.take(2).toList();

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.bgTop, AppColors.bgMid, AppColors.bgBottom],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),

                // "Hello, {name}"
                Text(
                  l10n.homeHello(state.userName),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                ImageQuoteCard(
                  imagePath: AppImages.quotes,
                  quote: AppConfig.quoteOfTheDay,
                ),
                const SizedBox(height: 18),

                const SizedBox(height: 10),
                const MoodCard(),

                const SizedBox(height: 12),

                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: WaterCard(
                          count: state.waterCount,
                          goal: state.waterGoal,
                          onAdd: homeCubit.incrementWater,
                          onRemove: homeCubit.decrementWater,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DetoxCard(
                          progress: state.detoxProgress,
                          onLockPhone: homeCubit.increaseDetox,
                          onReset: homeCubit.resetDetox,
                          isLocked: state.isPhoneLocked,
                          lockEndTime: state.lockEndTime,
                          onDisableLock: homeCubit.disableLock,
                          permissionDenied: state.permissionDenied,
                          onPermissionDeniedDismiss:
                              homeCubit.clearPermissionDenied,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                SectionCard(
                  title: l10n.todaysHabits,
                  trailing: GestureDetector(
                    onTap: onViewAllHabits,
                    child: Text(
                      l10n.homeViewAllHabits, // 'view all'
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  child: habitsToShow.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: Text(
                              '${l10n.noDailyHabits}\n${l10n.tapToAddHabit}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            for (int i = 0; i < habitsToShow.length; i++) ...[
                              HabitTile(
                                icon: habitsToShow[i].icon,
                                title: HabitLocalization.getLocalizedTitle(
                                  context, 
                                  habitsToShow[i],
                                ),
                                habitKey: habitsToShow[i].habitKey,
                                checked: habitsToShow[i].done,
                                onToggle: () {
                                  // Use habitKey instead of title
                                  homeCubit.toggleHabitCompletion(
                                    habitsToShow[i].habitKey,
                                    habitsToShow[i].done,
                                  );
                                },
                              ),
                              if (i < habitsToShow.length - 1)
                                const SizedBox(height: 8),
                            ],
                          ],
                        ),
                ),
                const SizedBox(height: 8),

                const SizedBox(height: 18),

                // Explore section
                Text(
                  l10n.exploreSectionTitle, // 'Explore'
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PlantArticlePage(),
                            ),
                          );
                        },
                        child: ExploreCard(
                          color: AppColors.mint,
                          title: l10n.explorePlantTitle,
                          cta: l10n.exploreReadNow,
                          assetImage: AppImages.plantIcon,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SportArticlePage(),
                            ),
                          );
                        },
                        child: ExploreCard(
                          color: AppColors.primary,
                          title: l10n.exploreSportsTitle,
                          cta: '',
                          assetImage: AppImages.boostMoodIcon,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}