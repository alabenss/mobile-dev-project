import 'package:flutter/material.dart';
import '../../themes/style_simple/colors.dart';
import 'habit_model.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;

  const HabitCard({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card.withOpacity(0.85),
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
        // Remove trailing entirely
        trailing: null,
      ),
    );
  }
}
