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
import '../../../logic/auth/auth_state.dart' as app_auth;
import '../../../utils/habit_localization.dart';

import '../articles/article_page.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onViewAllHabits;
  const HomeScreen({super.key, this.onViewAllHabits});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasLoadedData = false;

  Future<void> _onRefresh() async {
    final authState = context.read<AuthCubit>().state;

    if (authState.isAuthenticated && authState.user != null) {
      await context.read<HomeCubit>().loadInitial(
            userName: authState.user!.fullName,
            lang: 'en',
          );
    }
  }

  VoidCallback? get onViewAllHabits => widget.onViewAllHabits;

  String? _assetForSlug(String slug) {
    if (slug.startsWith('plants')) return AppImages.plantIcon;
    if (slug.startsWith('sports')) return AppImages.boostMoodIcon;
    return null;
  }

  Color _colorForSlug(String slug) {
    if (slug.startsWith('plants')) return AppColors.mint;
    if (slug.startsWith('sports')) return AppColors.primary;
    return Colors.white.withOpacity(.7);
  }

  T? _dailyPick<T>(List<T> items, String seedKey, int Function(T) stableHash) {
    if (items.isEmpty) return null;

    final now = DateTime.now().toUtc();
    final dayKey = now.year * 10000 + now.month * 100 + now.day;
    final seed = dayKey ^ seedKey.hashCode;
    final idx = (seed.abs()) % items.length;
    return items[idx];
  }

  @override
  void initState() {
    super.initState();
    // Load data only once when screen is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoadedData) {
        _loadHomeData();
        _hasLoadedData = true;
      }
    });
  }

  void _loadHomeData() {
    final authState = context.read<AuthCubit>().state;

    if (authState.isAuthenticated && authState.user != null) {
      context.read<HomeCubit>().loadInitial(
            userName: authState.user!.fullName,
            lang: 'en',
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AuthCubit, app_auth.AuthState>(
      listener: (context, authState) {
        // Only handle logout, not login (to avoid double loading)
        if (!authState.isAuthenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      },
      child: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          final homeCubit = context.read<HomeCubit>();
          final habitsToShow = state.dailyHabits.take(2).toList();

          final all = state.exploreArticles;
          final plants = all.where((a) => a.slug.startsWith('plants')).toList();
          final sports = all.where((a) => a.slug.startsWith('sports')).toList();

          final dailyPlant = _dailyPick(plants, 'plants', (a) => a.hashCode);
          final dailySport = _dailyPick(sports, 'sports', (a) => a.hashCode);

          final fallback1 = _dailyPick(all, 'any-1', (a) => a.hashCode);
          final fallback2 = _dailyPick(all, 'any-2', (a) => a.hashCode);

          final exploreToShow = <dynamic>[
            if (dailyPlant != null) dailyPlant else if (fallback1 != null) fallback1,
            if (dailySport != null) dailySport else if (fallback2 != null && fallback2 != fallback1) fallback2,
          ].whereType<dynamic>().toList();

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.bgTop, AppColors.bgMid, AppColors.bgBottom],
              ),
            ),
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),

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
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (all.isEmpty)
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
                                  imageUrl: (exploreToShow[i].heroImageUrl ?? '').trim(),
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
            ),
          );
        },
      ),
    );
  }
}