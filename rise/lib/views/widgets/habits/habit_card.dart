import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../themes/style_simple/colors.dart';
import '../../../models/habit_model.dart';
import '../../../utils/habit_localization.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback? onRestoreStreak;

  const HabitCard({
    super.key,
    required this.habit,
    this.onRestoreStreak,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final localizedTitle = HabitLocalization.getLocalizedTitle(context, habit);
    
    String frequencyText = habit.frequency;
    if (habit.frequency == 'Daily') {
      frequencyText = l10n.today;
    } else if (habit.frequency == 'Weekly') {
      frequencyText = l10n.weekly;
    } else if (habit.frequency == 'Monthly') {
      frequencyText = l10n.monthly;
    }

    // Determine card color based on habit type
    final cardColor = habit.habitType == 'bad'
        ? Colors.red.withOpacity(0.1)
        : AppColors.card.withOpacity(0.85);
    
    final borderColor = habit.habitType == 'bad'
        ? Colors.red.withOpacity(0.3)
        : Colors.transparent;

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: habit.habitType == 'bad'
                    ? Colors.red.withOpacity(0.2)
                    : Colors.green.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                habit.icon,
                color: habit.habitType == 'bad' ? Colors.red : AppColors.icon,
                size: 28,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    localizedTitle,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                // Task/Habit Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: habit.isTask
                        ? Colors.orange.withOpacity(0.2)
                        : Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: habit.isTask ? Colors.orange : Colors.blue,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        habit.isTask ? Icons.task_alt : Icons.verified,
                        size: 12,
                        color: habit.isTask ? Colors.orange : Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        habit.isTask ? 'Task' : 'Habit',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: habit.isTask ? Colors.orange : Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      habit.habitType == 'bad' ? Icons.close : Icons.check_circle,
                      size: 14,
                      color: habit.habitType == 'bad' ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      habit.habitType == 'bad' ? 'To Stop' : 'To Build',
                      style: TextStyle(
                        color: habit.habitType == 'bad' ? Colors.red : Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      habit.time != null 
                        ? 'at ${habit.time!.format(context)}'
                        : '',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Streak or Task Progress
                if (habit.isTask)
                  _buildTaskProgress(habit)
                else
                  _buildStreakInfo(habit, context),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.amber, Colors.orange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${habit.points}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Streak Restoration Option (controlled by parent)
          if (onRestoreStreak != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.restore, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Restore your ${habit.bestStreak}-day streak?',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Cost: ${habit.streakRestorationCost} points',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onRestoreStreak,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Restore',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskProgress(Habit habit) {
    final progress = habit.streakCount / 10;
    
    // FIXED: For bad habits, show progress when they resist (skip)
    // The streakCount represents successful resistances for bad habits
    // So we show the progress bar normally - it fills up as they resist more
    final progressColor = habit.habitType == 'bad' ? Colors.green : Colors.orange;
    
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${habit.streakCount}/10',
          style: TextStyle(
            color: progressColor,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakInfo(Habit habit, BuildContext context) {
    if (habit.streakCount == 0) {
      return Text(
        habit.bestStreak > 0 
            ? 'Best: ${habit.bestStreak} 🏆'
            : 'Start your streak!',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontStyle: FontStyle.italic,
        ),
      );
    }
    
    return Row(
      children: [
        Icon(
          Icons.local_fire_department,
          color: _getStreakColor(habit.streakCount),
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          '${habit.streakCount} ${_getStreakLabel(habit.frequency)}',
          style: TextStyle(
            color: _getStreakColor(habit.streakCount),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (habit.streakCount == habit.bestStreak && habit.bestStreak > 0)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Icon(
              Icons.emoji_events,
              color: Colors.amber,
              size: 14,
            ),
          ),
      ],
    );
  }

  Color _getStreakColor(int streak) {
    if (streak >= 30) return Colors.purple;
    if (streak >= 14) return Colors.red;
    if (streak >= 7) return Colors.orange;
    if (streak >= 3) return Colors.yellow.shade700;
    return Colors.grey;
  }

  String _getStreakLabel(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'daily':
        return 'days 🔥';
      case 'weekly':
        return 'weeks 🔥';
      case 'monthly':
        return 'months 🔥';
      default:
        return 'streak 🔥';
    }
  }
}