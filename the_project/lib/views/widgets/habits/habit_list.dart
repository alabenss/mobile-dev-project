import 'package:flutter/material.dart';
import '../../themes/style_simple/colors.dart';
import 'habit_model.dart';
import 'habit_card.dart';

class HabitList extends StatefulWidget {
  final List<Habit> habits;
  const HabitList({super.key, required this.habits});

  @override
  State<HabitList> createState() => _HabitListState();
}

class _HabitListState extends State<HabitList> {
  @override
  Widget build(BuildContext context) {
    if (widget.habits.isEmpty) {
      return const Center(
        child: Text(
          'No habits yet',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    int completedCount = widget.habits.where((h) => h.done).length;
    double progress =
        widget.habits.isEmpty ? 0 : completedCount / widget.habits.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              color: AppColors.accentPink,
              backgroundColor: Colors.white.withOpacity(0.3),
              minHeight: 8,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.habits.length,
            itemBuilder: (context, i) {
              final h = widget.habits[i];
              return HabitCard(
                habit: h,
                onReset: () => setState(() => h.done = false),
                onToggleDone: (val) => setState(() => h.done = val ?? false),
              );
            },
          ),
        ),
      ],
    );
  }
}
