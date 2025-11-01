import 'package:flutter/material.dart';
import '../../themes/style_simple/colors.dart';
import 'habit_model.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onReset;
  final ValueChanged<bool?> onToggleDone;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onReset,
    required this.onToggleDone,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.85),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(habit.icon, color: AppColors.accentPink),
        title: Text(
          habit.title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${habit.frequency}${habit.time != null ? " at ${habit.time!.format(context)}" : ""}',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.skip_next, color: Colors.grey.shade600),
              tooltip: "Reset progress",
              onPressed: onReset,
            ),
            Checkbox(
              activeColor: AppColors.accentPink,
              value: habit.done,
              onChanged: onToggleDone,
            ),
          ],
        ),
      ),
    );
  }
}
