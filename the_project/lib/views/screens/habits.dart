import 'package:flutter/material.dart';
import '../themes/style_simple/colors.dart';

class Habits extends StatefulWidget {
  const Habits({super.key});

  @override
  State<Habits> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<Habits>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final Map<String, List<Habit>> _habits = {
    'Daily': [
      Habit(title: 'Drink 2L water'),
      Habit(title: 'Meditate 10 mins'),
      Habit(title: 'Exercise'),
    ],
    'Weekly': [
      Habit(title: 'Call a friend'),
      Habit(title: 'Clean workspace'),
      Habit(title: 'Grocery shopping'),
    ],
    'Yearly': [
      Habit(title: 'Read 12 books'),
      Habit(title: 'Travel somewhere new'),
      Habit(title: 'Learn a new skill'),
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleHabit(Habit habit) {
    setState(() {
      habit.done = !habit.done;
    });
  }

  void _skipHabit(Habit habit) {
    setState(() {
      habit.skipped = !habit.skipped;
    });
  }

  void _addHabitDialog(String category) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Add new $category habit"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter habit name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPurple,
            ),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  _habits[category]!.add(Habit(title: text));
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  double _calculateProgress(List<Habit> habits) {
    if (habits.isEmpty) return 0;
    final done = habits.where((h) => h.done).length;
    return done / habits.length;
  }

  @override
  Widget build(BuildContext context) {
    final tabTitles = _habits.keys.toList();

    return Scaffold(
      backgroundColor: AppColors.bgBottom,
      appBar: AppBar(
        title: const Text('My Habits'),
        backgroundColor: AppColors.accentPurple,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            for (final title in tabTitles)
              Tab(text: title.toUpperCase()),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          for (final category in tabTitles)
            _buildHabitList(category, _habits[category]!),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentPurple,
        onPressed: () {
          final cat = tabTitles[_tabController.index];
          _addHabitDialog(cat);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHabitList(String category, List<Habit> habits) {
    final progress = _calculateProgress(habits);

    return Column(
      children: [
        // progress bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(0)}% achieved',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: progress,
                color: AppColors.accentPurple,
                backgroundColor: Colors.grey.shade300,
                minHeight: 8,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: habits.length,
            itemBuilder: (ctx, i) {
              final h = habits[i];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: IconButton(
                    icon: Icon(
                      h.done
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color:
                          h.done ? AppColors.accentPurple : Colors.grey,
                      size: 28,
                    ),
                    onPressed: () => _toggleHabit(h),
                  ),
                  title: Text(
                    h.title,
                    style: TextStyle(
                      fontSize: 16,
                      decoration: h.done
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: h.done ? Colors.grey : Colors.black,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.skip_next_rounded,
                      color: h.skipped
                          ? Colors.orange
                          : Colors.grey.shade500,
                    ),
                    onPressed: () => _skipHabit(h),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class Habit {
  final String title;
  bool done;
  bool skipped;

  Habit({
    required this.title,
    this.done = false,
    this.skipped = false,
  });
}
