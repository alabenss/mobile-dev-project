import 'package:flutter/material.dart';
import '../themes/style_simple/colors.dart';
import '../widgets/habits/habit_model.dart';
import '../widgets/habits/habit_list.dart';
import '../widgets/habits/add_habit_dialog.dart';

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
    final dailyHabits = _habits.where((h) => h.frequency == 'Daily').toList();
    final weeklyHabits = _habits.where((h) => h.frequency == 'Weekly').toList();
    final monthlyHabits =
        _habits.where((h) => h.frequency == 'Monthly').toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgTop, AppColors.bgMid, AppColors.bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildTabBar(),
              const SizedBox(height: 16),
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentPink,
        shape: const CircleBorder(),
        elevation: 6,
        onPressed: () async {
          final newHabit = await showDialog<Habit>(
            context: context,
            builder: (_) => const AddHabitDialog(),
          );
          if (newHabit != null) _addHabit(newHabit);
        },
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFE57F), Color(0xFFFF80AB)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(14),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.8),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
          ],
        ),
      ),
    );
  }
}
