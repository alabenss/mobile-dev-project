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
  List<Habit> completed = [];
  List<Habit> skipped = [];

  @override
  Widget build(BuildContext context) {
    // Filter remaining (not done, not skipped)
    final active = widget.habits
        .where((h) => !completed.contains(h) && !skipped.contains(h))
        .toList();

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
              color: AppColors.accentPink,
              backgroundColor: Colors.white.withOpacity(0.3),
              minHeight: 8,
            ),
          ),
        ),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (active.isNotEmpty) _buildSection("Today's Habits", active),
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
          padding:
              const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...habits.map((h) => Dismissible(
              key: ValueKey(h.title + title),
              direction: title == "Today's Habits"
                  ? DismissDirection.horizontal
                  : DismissDirection.none,
              background: _buildSwipeBackground(
                  Icons.check, Colors.greenAccent.withOpacity(0.7), "Completed"),
              secondaryBackground: _buildSwipeBackground(
                  Icons.close, Colors.redAccent.withOpacity(0.7), "Skipped",
                  alignRight: true),
              onDismissed: (direction) {
                setState(() {
                  if (direction == DismissDirection.startToEnd) {
                    completed.add(h);
                  } else {
                    skipped.add(h);
                  }
                });
              },
              child: Opacity(
                opacity: faded ? 0.6 : 1,
                child: HabitCard(
                  habit: h,
                  onReset: () => setState(() {
                    completed.remove(h);
                    skipped.remove(h);
                  }),
                  onToggleDone: (val) {},
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildSwipeBackground(IconData icon, Color color, String label,
      {bool alignRight = false}) {
    return Container(
      color: color,
      alignment:
          alignRight ? Alignment.centerRight : Alignment.centerLeft,
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
          if (!alignRight)
            const SizedBox(width: 8),
          if (!alignRight)
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}
