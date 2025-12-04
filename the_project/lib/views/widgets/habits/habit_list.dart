import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../themes/style_simple/colors.dart';
import '../../../models/habit_model.dart';
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
    // Separate habits by status
    final active = widget.habits
        .where((h) => !h.done && !h.skipped)
        .toList();
    final completed = widget.habits.where((h) => h.done).toList();
    final skipped = widget.habits
        .where((h) => h.skipped)
        .toList();
    
    // Calculate progress
    double progress = widget.habits.isEmpty
        ? 0
        : completed.length / widget.habits.length;

    return Column(
      children: [
        // Progress bar
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
                    'No habits yet!\nTap + to add your first habit',
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
                      _buildSection("Today's Habits", active),
                    if (completed.isNotEmpty)
                      _buildSection("Completed", completed, faded: true),
                    if (skipped.isNotEmpty) 
                    _buildSection("Skipped", skipped, faded: true),
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
              key: ValueKey('${habit.title}_${habit.frequency}_$title'),
              direction: title == "Today's Habits"
                  ? DismissDirection.horizontal
                  : DismissDirection.none,
              background: _buildSwipeBackground(
                Icons.check,
                Colors.greenAccent.withOpacity(0.7),
                "Completed",
              ),
              secondaryBackground: _buildSwipeBackground(
                Icons.close,
                Colors.redAccent.withOpacity(0.7),
                "Skipped",
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
                
                if (direction == DismissDirection.startToEnd) {
                  // Mark as completed
                  await cubit.completeHabit(habit.title);
                  
                  if (mounted) {
                    // Show points earned with animation
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('${habit.title} completed!'),
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
                } else if (direction == DismissDirection.endToStart) {
                  // Mark as skipped
                  await cubit.skipHabit(habit.title);
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${habit.title} skipped'),
                        backgroundColor: Colors.orangeAccent,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              child: GestureDetector(
                onLongPress: () async {
                  final shouldDelete = await _showDeleteConfirmation(context, habit);
                  if (shouldDelete && mounted) {
                    final cubit = context.read<HabitCubit>();
                    await cubit.deleteHabit(habit.title);
                    
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('🗑️ ${habit.title} deleted'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
                child: Opacity(
                  opacity: faded ? 0.6 : 1,
                  child: HabitCard(habit: habit),
                ),
              ),
            )),
      ],
    );
  }

  Future<bool> _showSkipConfirmation(BuildContext context, Habit habit) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.card,
            title: const Text('Skip Habit?'),
            content: Text(
              'Are you sure you want to skip "${habit.title}"?',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Skip',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, Habit habit) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.card,
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
                const SizedBox(width: 8),
                const Text('Delete Habit?'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to permanently delete "${habit.title}"?',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                const Text(
                  'This action cannot be undone.',
                  style: TextStyle(
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
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white),
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
                style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(width: 8),
          Icon(icon, color: Colors.white, size: 28),
          if (!alignRight) const SizedBox(width: 8),
          if (!alignRight)
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}