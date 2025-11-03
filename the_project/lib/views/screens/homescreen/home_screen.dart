import 'package:flutter/material.dart';
import '../../../commons/config.dart';
import '../../../commons/constants.dart';
import '../../themes/style_simple/colors.dart';
import '../../themes/style_simple/styles.dart';
import '../articles/plant_article.dart';
import '../articles/sport_article.dart';
// ✅ reuse the exact same component used in Journal
import '../../widgets/journal/mood_card.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onViewAllHabits;
  const HomeScreen({super.key, this.onViewAllHabits});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 💧 existing state
  int _waterCount = 4;
  final int _waterGoal = 8;
  double _detoxProgress = 0.35;
  bool _habitWalk = true;
  bool _habitRead = false;

  // 🙂 mood state now mirrors MoodCard’s API (keeps both screens consistent)
  String? _selectedMoodImage;
  String? _selectedMoodLabel;
  DateTime? _selectedMoodTime;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👋 Greeting section
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

          // Quote card
          _ImageQuoteCard(imagePath: AppImages.quotes, quote: AppConfig.quote),
          const SizedBox(height: 18),

          // ===================== MOOD (shared with Journal) =====================
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
          // =====================================================================

          const SizedBox(height: 12),

          // Water + Detox — equal height without overflow
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _WaterCard(
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
                  child: _DetoxCard(
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

          // Habits
          _SectionCard(
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
                _HabitTile(
                  icon: Icons.directions_walk,
                  title: 'Morning walk',
                  checked: _habitWalk,
                  onToggle: () => setState(() => _habitWalk = !_habitWalk),
                ),
                const SizedBox(height: 8),
                _HabitTile(
                  icon: Icons.menu_book_outlined,
                  title: 'Read 1 chapter',
                  checked: _habitRead,
                  onToggle: () => setState(() => _habitRead = !_habitRead),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Explore
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
                      MaterialPageRoute(
                        builder: (_) => const PlantArticlePage(),
                      ),
                    );
                  },
                  child: _ExploreCard(
                    color: const Color(0xFFCDEFE3),
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
                  child: _ExploreCard(
                    color: const Color(0xFFD7E6FF),
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
    );
  }
}

/// ---------- COMPONENTS BELOW ----------

class _ImageQuoteCard extends StatelessWidget {
  final String imagePath;
  final String quote;
  const _ImageQuoteCard({required this.imagePath, required this.quote});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 130,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(imagePath, fit: BoxFit.cover),
            Container(color: Colors.black.withOpacity(.25)),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  quote,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;
  const _SectionCard({required this.title, this.trailing, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppText.sectionTitle),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

// 🧊 NOTE: _MoodPicker class was removed — we now use MoodCard everywhere.
class _WaterCard extends StatelessWidget {
  final int count;
  final int goal;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  const _WaterCard({
    required this.count,
    required this.goal,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (count / goal).clamp(0, 1);
    final bool isGoalReached = count >= goal;

    return Card(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 150),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('water intake:', style: AppText.sectionTitle),
              const SizedBox(height: 6),
              Image.asset(
                'assets/images/water_intake.png',
                width: 32,
                height: 32,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('$count/$goal', style: AppText.chipBold),
                  const SizedBox(width: 6),
                  const Text('glasses', style: AppText.smallMuted),
                  const Spacer(),

                  // ✅ Reset button now same size & style as Digital Detox
                  if (isGoalReached)
                    SizedBox(
                      height: 30,
                      child: OutlinedButton(
                        onPressed: () {
                          for (int i = 0; i < goal; i++) {
                            onRemove();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.accentBlue,
                            width: 1.2,
                          ),
                          foregroundColor: AppColors.accentBlue,
                          textStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          minimumSize: const Size(58, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Reset'),
                      ),
                    )
                  else ...[
                    _TinyRoundBtn(icon: Icons.remove, onTap: onRemove),
                    const SizedBox(width: 6),
                    _TinyRoundBtn(icon: Icons.add, onTap: onAdd),
                  ],
                ],
              ),
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  color: AppColors.accentBlue,
                  backgroundColor: Colors.black.withOpacity(.06),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _TinyRoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _TinyRoundBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Material(
        color: Colors.black.withOpacity(.06),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Icon(icon, size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
// ...everything else unchanged above
class _DetoxCard extends StatelessWidget {
  final double progress;
  final VoidCallback onLockPhone;
  final VoidCallback onReset;
  const _DetoxCard({
    required this.progress,
    required this.onLockPhone,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final double p = progress.clamp(0, 1);
    final bool isComplete = p >= 1.0;

    return Card(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 150),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Digital detox:', style: AppText.sectionTitle),
              const SizedBox(height: 6),
              Image.asset('assets/images/phone_lock.png', width: 28, height: 28),
              const SizedBox(height: 8),

              // Percentage + Actions (matches water card behavior)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left: percentage text (always visible)
                  Expanded(
                    child: RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${(p * 100).round()}%',
                            style: AppText.chipBold,
                          ),
                          const TextSpan(
                            text: '  complete',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Right: action button
                  if (isComplete)
                    // ✅ Reset button styled exactly like water intake
                    SizedBox(
                      height: 30,
                      child: OutlinedButton(
                        onPressed: onReset,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.accentBlue,
                            width: 1.2,
                          ),
                          foregroundColor: AppColors.accentBlue,
                          textStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          minimumSize: const Size(58, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Reset'),
                      ),
                    )
                  else
                    SizedBox(
                      height: 30,
                      child: ElevatedButton(
                        onPressed: onLockPhone,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          textStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                          minimumSize: const Size(58, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Lock 30m'),
                      ),
                    ),
                ],
              ),

              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: p,
                  minHeight: 6,
                  color: AppColors.accentGreen,
                  backgroundColor: Colors.black.withOpacity(.06),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _HabitTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool checked;
  final VoidCallback onToggle;
  const _HabitTile({
    required this.icon,
    required this.title,
    required this.checked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.03),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accentPink),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              checked ? Icons.check_circle : Icons.radio_button_unchecked,
              color: checked ? AppColors.accentGreen : AppColors.navInactive,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreCard extends StatelessWidget {
  final Color color;
  final String title;
  final String cta;
  final String? assetImage;
  const _ExploreCard({
    required this.color,
    required this.title,
    required this.cta,
    this.assetImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (assetImage != null)
            Positioned(
              right: 8,
              bottom: 6,
              child: Image.asset(
                assetImage!,
                width: 90,
                height: 90,
                fit: BoxFit.contain,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SizedBox(
                    width: 150,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        height: 1.25,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                if (cta.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      cta,
                      style: const TextStyle(
                        color: AppColors.accentPink,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
