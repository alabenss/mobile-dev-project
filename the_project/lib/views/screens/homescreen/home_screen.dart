import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

class HomeScreen extends StatelessWidget {
  final VoidCallback? onViewAllHabits;
  const HomeScreen({super.key, this.onViewAllHabits});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        final homeCubit = context.read<HomeCubit>();

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
                const Text(
                  "Good morning, ala",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                ImageQuoteCard(
                  imagePath: AppImages.quotes,
                  quote: AppConfig.quote,
                ),
                const SizedBox(height: 18),

                const SizedBox(height: 10),
                MoodCard(
                  selectedMood: state.selectedMoodImage,
                  selectedMoodLabel: state.selectedMoodLabel,
                  selectedTime: state.selectedMoodTime,
                  onMoodSelected: (moodImage, moodLabel) {
                    homeCubit.setMood(moodImage, moodLabel);
                  },
                ),

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
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                SectionCard(
                  title: 'Daily habits:',
                  trailing: GestureDetector(
                    onTap: onViewAllHabits,
                    child: const Text(
                      'view all',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      HabitTile(
                        icon: Icons.directions_walk,
                        title: 'Morning walk',
                        checked: state.habitWalk,
                        onToggle: homeCubit.toggleHabitWalk,
                      ),
                      const SizedBox(height: 8),
                      HabitTile(
                        icon: Icons.menu_book_outlined,
                        title: 'Read 1 chapter',
                        checked: state.habitRead,
                        onToggle: homeCubit.toggleHabitRead,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                const SizedBox(height: 18),

                const Text(
                  'Explore',
                  style: TextStyle(
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
                          title: 'The calming effect of plants',
                          cta: 'Read Now',
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
                          title: 'Boost your\nmood with\nsports',
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
