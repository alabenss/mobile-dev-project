import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_project/l10n/app_localizations.dart';

import '../../../commons/config.dart';
import '../../../commons/constants.dart';
import '../../themes/style_simple/colors.dart';
import '../../widgets/journal/mood_card.dart';

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

import '../articles/article_page.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onViewAllHabits;
  const HomeScreen({super.key, this.onViewAllHabits});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  VoidCallback? get onViewAllHabits => widget.onViewAllHabits;

  // fallback assets/colors for known slugs (optional)
  String? _assetForSlug(String slug) {
    switch (slug) {
      case 'plants':
        return AppImages.plantIcon;
      case 'sports':
        return AppImages.boostMoodIcon;
      default:
        return null;
    }
  }

  Color _colorForSlug(String slug) {
    switch (slug) {
      case 'plants':
        return AppColors.mint;
      case 'sports':
        return AppColors.primary;
      default:
        return Colors.white.withOpacity(.7);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;

      if (authState.isAuthenticated && authState.user != null) {
        context.read<HomeCubit>().loadInitial(
              userName: authState.user!.name,
              lang: 'en', // later you can pass locale here
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final homeCubit = context.read<HomeCubit>();
        final habitsToShow = state.dailyHabits.take(2).toList();
        final exploreToShow = state.exploreArticles.take(2).toList();

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

                // 👋 Hello
                Text(
                  l10n.homeHello(state.userName),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                ImageQuoteCard(
                  imagePath: AppImages.quotes,
                  quote: AppConfig.quoteOfTheDay(context),
                ),

                const SizedBox(height: 18),
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
                      const SizedBox(width: 2),
                      Expanded(
                        child: DetoxCard(
                          progress: state.detoxProgress,
                          onLockPhone: homeCubit.increaseDetox,
                          onReset: homeCubit.resetDetox,
                          isLocked: state.isPhoneLocked,
                          lockEndTime: state.lockEndTime,
                          onDisableLock: homeCubit.disableLock,
                          permissionDenied: state.permissionDenied,
                          onPermissionDeniedDismiss: homeCubit.clearPermissionDenied,
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
                      l10n.homeViewAllHabits,
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
                                  homeCubit.toggleHabitCompletion(
                                    habitsToShow[i].habitKey,
                                    habitsToShow[i].done,
                                  );
                                },
                              ),
                              if (i < habitsToShow.length - 1) const SizedBox(height: 8),
                            ],
                          ],
                        ),
                ),

                const SizedBox(height: 18),

                Text(
                  l10n.exploreSectionTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 10),

                if (state.exploreLoading)
                  const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: CircularProgressIndicator(),
                  ))
                else if (exploreToShow.isEmpty)
                  Text(
                    state.exploreError ?? 'No articles yet.',
                    style: const TextStyle(color: AppColors.textSecondary),
                  )
                else
                  Row(
                    children: [
                      for (int i = 0; i < exploreToShow.length; i++) ...[
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ArticlePage(
                                    slug: exploreToShow[i].slug,
                                    lang: 'en',
                                  ),
                                ),
                              );
                            },
                            child: ExploreCard(
                              color: _colorForSlug(exploreToShow[i].slug),
                              title: exploreToShow[i].title,
                              cta: l10n.exploreReadNow,
                              assetImage: _assetForSlug(exploreToShow[i].slug),
                              imageUrl: exploreToShow[i].heroImageUrl, // online if available
                            ),
                          ),
                        ),
                        if (i < exploreToShow.length - 1) const SizedBox(width: 12),
                      ],
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
