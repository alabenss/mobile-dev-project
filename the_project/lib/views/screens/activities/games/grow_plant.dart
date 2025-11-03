
import 'package:flutter/material.dart';
import '../../../themes/style_simple/colors.dart';
import '../../../widgets/activity_shell.dart';
import '../../habits_screen.dart'; 

class GrowPlantPage extends StatelessWidget {
  const GrowPlantPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ActivityShell(
      title: 'Grow the plant',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          children: [
            // Headline / helper text
            _SoftCard(
              child: Column(
                children: const [
                  SizedBox(height: 6),
                  Text(
                    'Nurture your plant with water and sunlight.\n'
                    'Spend activity points to help it grow!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.35,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Plant preview
            _SoftCard(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
              child: Column(
                children: [
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.06),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const _PlantIllustration(),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Stage: Sprout',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Points summary (navigates to habits.dart)
            _SoftCard(
              child: Row(
                children: [
                  const Icon(Icons.stars_rounded,
                      color: AppColors.accentOrange),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Available points: 20',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HabitsScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accentPink,
                      side: const BorderSide(color: AppColors.accentPink),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Get points'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Meters (static UI)
            _SoftCard(
              child: Column(
                children: const [
                  _MeterTile(
                    label: 'Water',
                    icon: Icons.water_drop_rounded,
                    color: AppColors.accentBlue,
                    value: 0.60,
                    actionLabel: 'Water (5)',
                    helper: 'Spend 5 pts',
                  ),
                  SizedBox(height: 12),
                  _MeterTile(
                    label: 'Sunlight',
                    icon: Icons.wb_sunny_rounded,
                    color: AppColors.accentOrange,
                    value: 0.40,
                    actionLabel: 'Sun (4)',
                    helper: 'Spend 4 pts',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Tip card
            _SoftCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.eco_rounded, color: AppColors.accentGreen),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tip: when both bars are full, your plant will grow to the next stage.',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const _SoftCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1E9),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _MeterTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final double value;
  final String actionLabel;
  final String helper;

  const _MeterTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.value,
    required this.actionLabel,
    required this.helper,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (value * 100).round();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '$pct%',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              color: color,
              backgroundColor: Colors.black.withOpacity(.06),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                helper,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                child: Text(actionLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlantIllustration extends StatelessWidget {
  const _PlantIllustration();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pot
          Positioned(
            bottom: 48,
            child: Container(
              width: 120,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFD9A07C),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            child: Container(
              width: 140,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFE6B393),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Stem
          Positioned(
            bottom: 118,
            child: Container(
              width: 12,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF76C893),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),

          // Leaves
          Positioned(
            bottom: 165,
            child: Row(
              children: [
                _leaf(angle: -18),
                const SizedBox(width: 6),
                _leaf(angle: 18),
              ],
            ),
          ),

          // Bud
          Positioned(
            bottom: 188,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Color(0xFF2DBE7B),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _leaf({required double angle}) {
    return Transform.rotate(
      angle: angle * 3.14159 / 180,
      child: Container(
        width: 64,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFF80ED99),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
      ),
    );
  }
}
