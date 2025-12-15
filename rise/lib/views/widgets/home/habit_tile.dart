import 'package:flutter/material.dart';
import '../../themes/style_simple/colors.dart';

class HabitTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String habitKey; // Add habitKey parameter
  final bool checked;
  final VoidCallback onToggle;
  
  const HabitTile({
    super.key,
    required this.icon,
    required this.title,
    required this.habitKey, // Required parameter
    required this.checked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.icon),
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
      ),
    );
  }
}