import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../l10n/app_localizations.dart';
import '../../themes/style_simple/colors.dart';

import '../../../models/habit_model.dart';
import '../../widgets/habits/habit_list.dart';
import '../../widgets/habits/add_habit_dialog.dart';

import '../../../logic/habits/habit_cubit.dart';
import '../../../logic/habits/habit_state.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load habits when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<HabitCubit>().loadHabits();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
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
              _buildTabBar(l10n),
              const SizedBox(height: 16),

              /// Listen to Cubit state
              Expanded(
                child: BlocConsumer<HabitCubit, HabitState>(
                  listener: (context, state) {
                    // Show error if any
                    if (state.error != null && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.error!),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      context.read<HabitCubit>().clearError();
                    }
                  },
                  builder: (context, state) {
                    // Show loading indicator
                    if (state.isLoading && state.habits.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.icon,
                        ),
                      );
                    }

                    // Filter habits by frequency
                    final daily = state.habits
                        .where((h) => h.frequency == 'Daily')
                        .toList();
                    final weekly = state.habits
                        .where((h) => h.frequency == 'Weekly')
                        .toList();
                    final monthly = state.habits
                        .where((h) => h.frequency == 'Monthly')
                        .toList();

                    return TabBarView(
                      controller: _tabController,
                      children: [
                        daily.isEmpty 
                          ? _buildEmptyState(l10n, 'Daily')
                          : HabitList(habits: daily),
                        weekly.isEmpty 
                          ? _buildEmptyState(l10n, 'Weekly')
                          : HabitList(habits: weekly),
                        monthly.isEmpty 
                          ? _buildEmptyState(l10n, 'Monthly')
                          : HabitList(habits: monthly),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.icon,
        shape: const CircleBorder(),
        elevation: 6,
        onPressed: () async {
          final newHabit = await showDialog<Habit>(
            context: context,
            builder: (_) => AddHabitDialog(
              existingHabits: context.read<HabitCubit>().state.habits,
            ),
          );

          if (newHabit != null && mounted) {
            // Add habit through cubit (will save to database)
            context.read<HabitCubit>().addHabit(newHabit);
          }
        },
        child: const Icon(Icons.add, color: AppColors.textlight, size: 28),
      ),
    );
  }

  Widget _buildTabBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 234, 148),
              Color.fromARGB(255, 254, 148, 184)
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
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
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            color: AppColors.textlight.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20),
          ),
          labelColor: AppColors.textlight,
          unselectedLabelColor: AppColors.textlight.withOpacity(0.8),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          tabs: [
            Tab(text: l10n.today),
            Tab(text: l10n.weekly),
            Tab(text: l10n.monthly),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, String frequencyType) {
    String message = '';
    switch (frequencyType) {
      case 'Daily':
        message = l10n.noDailyHabits;
        break;
      case 'Weekly':
        message = l10n.noWeeklyHabits;
        break;
      case 'Monthly':
        message = l10n.noMonthlyHabits;
        break;
      default:
        message = l10n.noHabitsYet;
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checklist_rounded,
            size: 60,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.tapToAddHabit,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}