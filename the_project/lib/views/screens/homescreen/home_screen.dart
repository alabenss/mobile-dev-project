import 'package:flutter/material.dart';
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

class HomeScreen extends StatefulWidget {
  final VoidCallback? onViewAllHabits;
  const HomeScreen({super.key, this.onViewAllHabits});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _waterCount = 4;
  final int _waterGoal = 8;
  double _detoxProgress = 0.35;
  bool _habitWalk = true;
  bool _habitRead = false;

  String? _selectedMoodImage;
  String? _selectedMoodLabel;
  DateTime? _selectedMoodTime;

  @override
  Widget build(BuildContext context) {
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

            ImageQuoteCard(imagePath: AppImages.quotes, quote: AppConfig.quote),
            const SizedBox(height: 18),

            const SizedBox(height: 10),
            MoodCard(
              selectedMood: _selectedMoodImage,
              selectedMoodLabel: _selectedMoodLabel,
              selectedTime: _selectedMoodTime,
              onMoodSelected: (moodImage, moodLabel) {
                setState(() {
                  final isReset = moodImage.isEmpty && moodLabel.isEmpty;
                  if (isReset) {
                    _selectedMoodImage = null;
                    _selectedMoodLabel = null;
                    _selectedMoodTime = null;
                  } else {
                    _selectedMoodImage = moodImage;
                    _selectedMoodLabel = moodLabel;
                    _selectedMoodTime = DateTime.now();
                  }
                });
              },
            ),

            const SizedBox(height: 12),

            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: WaterCard(
                      count: _waterCount,
                      goal: _waterGoal,
                      onAdd: () {
                        if (_waterCount < _waterGoal) {
                          setState(() => _waterCount++);
                        }
                      },
                      onRemove: () {
                        if (_waterCount > 0) {
                          setState(() => _waterCount--);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DetoxCard(
                      progress: _detoxProgress,
                      onLockPhone: () {
                        setState(() {
                          _detoxProgress += 0.1;
                          if (_detoxProgress > 1) _detoxProgress = 1;
                        });
                      },
                      onReset: () {
                        setState(() => _detoxProgress = 0);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            SectionCard(
              title: 'Daily habits:',
              trailing: GestureDetector(
                onTap: widget.onViewAllHabits,
                child: const Text(
                  'view all',
                  style: TextStyle(
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              child: Column(
                children: [
                  HabitTile(
                    icon: Icons.directions_walk,
                    title: 'Morning walk',
                    checked: _habitWalk,
                    onToggle: () => setState(() => _habitWalk = !_habitWalk),
                  ),
                  const SizedBox(height: 8),
                  HabitTile(
                    icon: Icons.menu_book_outlined,
                    title: 'Read 1 chapter',
                    checked: _habitRead,
                    onToggle: () => setState(() => _habitRead = !_habitRead),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            const Text(
              'Explore',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PlantArticlePage()),
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
                        MaterialPageRoute(builder: (_) => const SportArticlePage()),
                      );
                    },
                    child: ExploreCard(
                      color: AppColors.sky,
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
  }
}
