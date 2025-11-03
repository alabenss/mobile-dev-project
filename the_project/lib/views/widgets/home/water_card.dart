import 'package:flutter/material.dart';
import '../../themes/style_simple/colors.dart';
import '../../themes/style_simple/styles.dart';

class WaterCard extends StatelessWidget {
  final int count;
  final int goal;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  const WaterCard({
    super.key,
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
      color: AppColors.card,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 150),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('water intake:', style: AppText.sectionTitle),
              const SizedBox(height: 6),
              Image.asset('assets/images/water_intake.png', width: 32, height: 32),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('$count/$goal', style: AppText.chipBold),
                  const SizedBox(width: 6),
                  const Text('glasses', style: AppText.smallMuted),
                  const Spacer(),
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
                          side: const BorderSide(color: AppColors.accentBlue, width: 1.2),
                          foregroundColor: AppColors.accentBlue,
                          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                  backgroundColor: AppColors.backgroundColor,
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
        color: AppColors.backgroundColor,
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
