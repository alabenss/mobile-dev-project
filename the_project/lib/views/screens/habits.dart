import 'package:flutter/material.dart';
import '../themes/style_simple/colors.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Habit> _habits = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _addHabit(Habit habit) {
    setState(() {
      _habits.add(habit);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dailyHabits =
        _habits.where((h) => h.frequency == 'Daily').toList();
    final weeklyHabits =
        _habits.where((h) => h.frequency == 'Weekly').toList();
    final monthlyHabits =
        _habits.where((h) => h.frequency == 'Monthly').toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // 📅 Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.accentPurple,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  tabs: const [
                    Tab(text: 'Daily'),
                    Tab(text: 'Weekly'),
                    Tab(text: 'Monthly'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 🪄 Habit lists for each tab
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  HabitList(habits: dailyHabits),
                  HabitList(habits: weeklyHabits),
                  HabitList(habits: monthlyHabits),
                ],
              ),
            ),
          ],
        ),
      ),

      // ➕ Floating button to add habit
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentPurple,
        onPressed: () async {
          final newHabit = await showDialog<Habit>(
            context: context,
            builder: (_) => AddHabitDialog(),
          );
          if (newHabit != null) _addHabit(newHabit);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// -------------------- Habit Model --------------------
class Habit {
  final String title;
  final String frequency; // daily, weekly, monthly, yearly
  final TimeOfDay? time;
  final bool reminder;
  bool done;

  Habit({
    required this.title,
    required this.frequency,
    this.time,
    this.reminder = false,
    this.done = false,
  });
}

// -------------------- Habit List --------------------
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
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    int completedCount =
        widget.habits.where((h) => h.done).length;
    double progress =
        widget.habits.isEmpty ? 0 : completedCount / widget.habits.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: LinearProgressIndicator(
            value: progress,
            color: AppColors.accentPurple,
            backgroundColor: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.habits.length,
            itemBuilder: (context, i) {
              final h = widget.habits[i];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
                child: ListTile(
                  title: Text(h.title),
                  subtitle: Text(
                    '${h.frequency} ${h.time != null ? "at ${h.time!.format(context)}" : ""}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.skip_next,
                            color: Colors.grey.shade600),
                        onPressed: () {
                          setState(() {
                            h.done = false;
                          });
                        },
                      ),
                      Checkbox(
                        activeColor: AppColors.accentPurple,
                        value: h.done,
                        onChanged: (val) {
                          setState(() {
                            h.done = val ?? false;
                          });
                        },
                      ),
                    ],
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

// -------------------- Add Habit Dialog --------------------
class AddHabitDialog extends StatefulWidget {
  @override
  State<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  final TextEditingController _nameCtrl = TextEditingController();
  String _frequency = 'Daily';
  TimeOfDay? _time;
  bool _reminder = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Habit'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Habit name',
              ),
            ),
            const SizedBox(height: 12),

            // Frequency dropdown
            DropdownButtonFormField<String>(
              value: _frequency,
              items: const [
                DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
                DropdownMenuItem(value: 'Yearly', child: Text('Yearly')),
              ],
              onChanged: (v) => setState(() => _frequency = v!),
              decoration: const InputDecoration(labelText: 'Frequency'),
            ),
            const SizedBox(height: 12),

            // Time picker
            Row(
              children: [
                const Text('Time:'),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (picked != null) setState(() => _time = picked);
                  },
                  child: Text(
                    _time != null
                        ? _time!.format(context)
                        : 'Select time',
                    style: const TextStyle(
                      color: AppColors.accentPurple,
                    ),
                  ),
                ),
              ],
            ),

            // Reminder toggle
            SwitchListTile(
              title: const Text('Set Reminder'),
              activeColor: AppColors.accentPurple,
              value: _reminder,
              onChanged: (v) => setState(() => _reminder = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentPurple,
          ),
          onPressed: () {
            if (_nameCtrl.text.trim().isEmpty) return;
            Navigator.pop(
              context,
              Habit(
                title: _nameCtrl.text.trim(),
                frequency: _frequency,
                time: _time,
                reminder: _reminder,
              ),
            );
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
