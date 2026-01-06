import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../l10n/app_localizations.dart';
import '../../themes/style_simple/colors.dart';
import '../../../models/habit_model.dart';
import '../../../database/repo/habit_repo.dart';
import 'habit_card.dart';
import '../../../logic/habits/habit_cubit.dart';

class HabitList extends StatefulWidget {
  final List<Habit> habits;
  const HabitList({super.key, required this.habits});

  @override
  State<HabitList> createState() => _HabitListState();
}

class _HabitListState extends State<HabitList> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final active = widget.habits
        .where((h) => !h.done && !h.skipped)
        .toList();
    final completed = widget.habits.where((h) => h.done).toList();
    final skipped = widget.habits
        .where((h) => h.skipped)
        .toList();
    
    double progress = widget.habits.isEmpty
        ? 0
        : completed.length / widget.habits.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              color: AppColors.icon,
              backgroundColor: Colors.white.withOpacity(0.3),
              minHeight: 8,
            ),
          ),
        ),

        Expanded(
          child: widget.habits.isEmpty
              ? Center(
                  child: Text(
                    l10n.noHabitsYet,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (active.isNotEmpty)
                      _buildSection(l10n.todaysHabits, active),
                    if (completed.isNotEmpty)
                      _buildSection(l10n.completed, completed, faded: true),
                    if (skipped.isNotEmpty) 
                      _buildSection(l10n.skipped, skipped, faded: true),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Habit> habits,
      {bool faded = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...habits.map((habit) => Dismissible(
              key: ValueKey('${habit.habitKey}_${habit.frequency}_$title'),
              direction: title == "Today's Habits" || title == "Habits d'aujourd'hui"
                  ? DismissDirection.horizontal
                  : DismissDirection.none,
              // REVERSED COLORS FOR BAD HABITS - Using dialog-style icons
              background: _buildSwipeBackground(
                habit.habitType == 'bad' ? Icons.cancel : Icons.check_circle,
                habit.habitType == 'bad' 
                    ? Colors.redAccent.withOpacity(0.7)  // Red for bad habit "done"
                    : Colors.greenAccent.withOpacity(0.7), // Green for good habit completed
                habit.habitType == 'good' ? "Completed" : "Did It 😢",
              ),
              secondaryBackground: _buildSwipeBackground(
                habit.habitType == 'good' ? Icons.cancel : Icons.check_circle,
                habit.habitType == 'good' 
                    ? Colors.redAccent.withOpacity(0.7)  // Red for good habit skipped
                    : Colors.greenAccent.withOpacity(0.7), // Green for bad habit resisted
                habit.habitType == 'good' ? "Skipped" : "Resisted! 💪",
                alignRight: true,
              ),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.endToStart) {
                  return await _showSkipConfirmation(context, habit);
                }
                return true;
              },
              onDismissed: (direction) async {
                final cubit = context.read<HabitCubit>();
                final l10n = AppLocalizations.of(context)!;
                
                if (direction == DismissDirection.startToEnd) {
                  if (habit.habitType == 'good') {
                    await cubit.completeHabit(habit.habitKey);
                    
                    if (mounted) {
                      String message = l10n.habitCompleted(habit.title);
                      
                      // Special message if task became habit
                      if (habit.isTask && habit.taskCompletionCount == 9) {
                        message = '🎉 ${habit.title} is now a Habit! +50 bonus points!';
                      }
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.white),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(message),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.stars,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '+${habit.points}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.greenAccent,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  } else {
                    // Bad habit - marking as "done" (did the bad habit) breaks the streak
                    await cubit.completeHabit(habit.habitKey);
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Oh no! You did ${habit.title}. Streak broken! 😞'),
                          backgroundColor: Colors.redAccent,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                } else if (direction == DismissDirection.endToStart) {
                  if (habit.habitType == 'good') {
                    // Good habit skipped
                    await cubit.skipHabit(habit.habitKey);
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.habitSkipped(habit.title)),
                          backgroundColor: Colors.orangeAccent,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  } else {
                    // Bad habit resisted - this is good!
                    await cubit.skipHabit(habit.habitKey);
                    
                    if (mounted) {
                      String message = 'Great! You resisted ${habit.title}! 💪';
                      
                      if (habit.isTask && habit.taskCompletionCount == 9) {
                        message = '🎉 Resisting ${habit.title} is now a Habit! +50 bonus!';
                      }
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.celebration, color: Colors.white),
                              const SizedBox(width: 8),
                              Expanded(child: Text(message)),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.stars, color: Colors.white, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      '+${habit.points}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.greenAccent,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                }
              },
              child: GestureDetector(
                onLongPress: () async {
                  final shouldDelete = await _showDeleteConfirmation(context, habit);
                  if (shouldDelete && mounted) {
                    final cubit = context.read<HabitCubit>();
                    final l10n = AppLocalizations.of(context)!;
                    await cubit.deleteHabit(habit.habitKey);
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.habitDeleted(habit.title)),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
                child: Opacity(
                  opacity: faded ? 0.6 : 1,
                  child: HabitCard(
                    habit: habit,
                    onRestoreStreak: habit.needsStreakRestoration
                        ? () => _handleRestoreStreak(context, habit)
                        : null,
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Future<void> _handleRestoreStreak(BuildContext context, Habit habit) async {
    final l10n = AppLocalizations.of(context)!;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Row(
          children: [
            Icon(Icons.restore, color: Colors.orange, size: 28),
            const SizedBox(width: 8),
            Text('Restore Streak?'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Restore your ${habit.bestStreak}-day streak for ${habit.habitKey}?',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.stars, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    'Cost: ${habit.streakRestorationCost} points',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel, style: TextStyle(color: AppColors.textPrimary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.pop(context, true),
            child: Text('Restore', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    if (confirmed == true && mounted) {
      final repo = HabitRepository();
      final success = await repo.restoreStreak(habit.habitKey);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Streak restored! Keep it going! 🔥'),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          
          // Reload habits to show updated streak
          context.read<HabitCubit>().loadHabits();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Not enough points to restore streak!'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Future<bool> _showSkipConfirmation(BuildContext context, Habit habit) async {
    final l10n = AppLocalizations.of(context)!;
    
    String title;
    String message;
    
    if (habit.habitType == 'good') {
      title = l10n.skipHabit;
      message = l10n.skipHabitConfirmation(habit.title);
    } else {
      title = 'Resist ${habit.title}?';
      message = 'Mark that you successfully resisted this habit today?';
    }
    
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.card,
            title: Text(title),
            content: Text(
              message,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  l10n.cancel,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: habit.habitType == 'good' 
                      ? Colors.orangeAccent 
                      : Colors.green,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  habit.habitType == 'good' ? l10n.skip : 'Resisted',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, Habit habit) async {
    final l10n = AppLocalizations.of(context)!;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.card,
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
                const SizedBox(width: 8),
                Text(l10n.deleteHabit),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.deleteHabitConfirmation(habit.title),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.actionCannotBeUndone,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  l10n.cancel,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  l10n.delete,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildSwipeBackground(IconData icon, Color color, String label,
      {bool alignRight = false}) {
    return Container(
      color: color,
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment:
            alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (alignRight)
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Icon(icon, color: Colors.white, size: 32),
          if (!alignRight) const SizedBox(width: 8),
          if (!alignRight)
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}