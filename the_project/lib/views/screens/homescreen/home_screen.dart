import 'package:flutter/material.dart';
import '../../../commons/config.dart';
import '../../../commons/constants.dart';
import '../../themes/style_simple/colors.dart';
import '../../themes/style_simple/styles.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;        // Home tab by default
  int _moodIndex = 1;       // default selected mood (0..5). 1 matches your screenshot

  @override
  Widget build(BuildContext context) {
    return Container(
      // Whole-page gradient background
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.bgTop, AppColors.bgMid, AppColors.bgBottom],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quote image card
              const _ImageQuoteCard(
                imagePath: AppImages.quotes, // make sure pubspec.yaml has assets/images/
                quote: AppConfig.quote,
              ),
              const SizedBox(height: 18),

              // Mood row (updated)
              _SectionCard(
                title: 'How are you feeling today ?',
                trailing: const Text(
                  'journal',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: _MoodPicker(
                    selected: _moodIndex,
                    onChanged: (i) => setState(() => _moodIndex = i),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Water + Detox
              const Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'water intake:',
                      icon: Icons.local_drink_outlined,
                      value: '4/8',
                      subtitle: 'glasses',
                      progress: 0.5,
                      progressColor: AppColors.accentBlue,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      title: 'Digital detox:',
                      icon: Icons.no_cell,
                      value: '2h24m',
                      subtitle: 'left',
                      progress: 0.35,
                      progressColor: AppColors.accentGreen,
                      showBan: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Habits
              const _SectionCard(
                title: 'Daily habits:',
                trailing: Text(
                  'view all',
                  style: TextStyle(
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                child: Column(
                  children: [
                    _HabitTile(
                      icon: Icons.directions_walk,
                      title: 'Morning walk',
                      checked: true,
                    ),
                    SizedBox(height: 8),
                    _HabitTile(
                      icon: Icons.menu_book_outlined,
                      title: 'Read 1 chapter',
                      checked: false,
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
              const Row(
                children: [
                  Expanded(
                    child: _ExploreCard(
                      color: Color(0xFFCDEFE3),
                      title: 'The calming effect of plants',
                      cta: 'Read Now',
                      assetImage: AppImages.plantIcon,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _ExploreCard(
                      color: Color(0xFFD7E6FF),
                      title: 'Boost your\nmood with\nsports',
                      cta: '',
                      assetImage: AppImages.boostMoodIcon,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomPillNav(
          index: _navIndex,
          onTap: (i) => setState(() => _navIndex = i),
        ),
      ),
    );
  }
}

// ------- COMPONENTS -------

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

/// Mood picker with 6 moods and square outline for the selected one.
/// Uses emoji faces on top of a sun icon look.
/// If you have PNGs, swap the Icon/Emoji with Image.asset('assets/mood/0.png') etc.
class _MoodPicker extends StatelessWidget {
  final int selected;              // 0..5
  final ValueChanged<int> onChanged;

  const _MoodPicker({required this.selected, required this.onChanged});

static const _faces = <String>['🌞','🌤️','🌥️','🌦️','🌧️','🌩️'];


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        final bool isSelected = selected == i;
        return GestureDetector(
          onTap: () => onChanged(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2F4),
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: Colors.black87, width: 1.2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                )
              ],
            ),
            child: Text(
              _faces[i],
              style: const TextStyle(fontSize: 24),
            ),
          ),
        );
      }),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final String subtitle;
  final double progress;
  final Color progressColor;
  final bool showBan;

  const _MetricCard({
    required this.title,
    required this.icon,
    required this.value,
    required this.subtitle,
    required this.progress,
    required this.progressColor,
    this.showBan = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppText.sectionTitle),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(icon, color: progressColor),
                if (showBan)
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(Icons.not_interested, size: 18, color: Colors.red),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value, style: AppText.chipBold),
                const SizedBox(width: 6),
                Text(subtitle, style: AppText.smallMuted),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                color: progressColor,
                backgroundColor: Colors.black.withOpacity(.06),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool checked;
  const _HabitTile({required this.icon, required this.title, required this.checked});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
          ),
          Icon(
            checked ? Icons.check_circle : Icons.radio_button_unchecked,
            color: checked ? AppColors.accentGreen : AppColors.navInactive,
          ),
        ],
      ),
    );
  }
}

class _ExploreCard extends StatelessWidget {
  final Color color;
  final String title;
  final String cta;
  final String? assetImage; // NEW: optional bottom-right art

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
      clipBehavior: Clip.antiAlias, // keep rounded corners on the image
      child: Stack(
        children: [
          // Bottom-right illustration
          if (assetImage != null)
            Positioned(
              right: 8,
              bottom: 6,
              child: Image.asset(
                assetImage!,
                width: 90, // tweak to taste
                height: 90,
                fit: BoxFit.contain,
              ),
            ),

          // Text + CTA
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // keep text away from the image area
                Expanded(
                  child: SizedBox(
                    width: 150, // prevents text overlapping the image
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
                        horizontal: 12, vertical: 6),
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

