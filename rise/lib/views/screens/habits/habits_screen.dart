import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../l10n/app_localizations.dart';
import '../../themes/style_simple/colors.dart';

import '../../../models/habit_model.dart';
import '../../widgets/habits/habit_list.dart';
import '../../widgets/habits/add_habit_dialog.dart';
import '../../widgets/error_dialog.dart';

import '../../../logic/habits/habit_cubit.dart';
import '../../../logic/habits/habit_state.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen>
    with SingleTickerProviderStateMixin {
  Future<void> _onRefresh() async {
    await context.read<HabitCubit>().loadHabits();
  }

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

  void _showErrorDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AppErrorDialog(
        title: title,
        message: message,
      ),
    );
  }

  String _getErrorTitle(String error) {
    final l10n = AppLocalizations.of(context)!;
    
    if (error.toLowerCase().contains('already exists')) {
      return l10n.habitErrorAlreadyExists;
    }
    
    if (error.toLowerCase().contains('network') || 
        error.toLowerCase().contains('connection') ||
        error.toLowerCase().contains('internet')) {
      return l10n.noInternetConnection;
    }
    
    if (error.toLowerCase().contains('failed') || 
        error.toLowerCase().contains('error')) {
      return l10n.habitErrorOperationFailed;
    }
    
    return l10n.habitErrorGeneral;
  }

  String _getErrorMessage(String error) {
    final l10n = AppLocalizations.of(context)!;
    
    // Already exists
    if (error.toLowerCase().contains('already exists')) {
      return l10n.habitErrorMessageAlreadyExists;
    }
    
    // Network errors
    if (error.toLowerCase().contains('network') || 
        error.toLowerCase().contains('connection') ||
        error.toLowerCase().contains('internet')) {
      return l10n.errorMessageNoInternet;
    }
    
    // Generic operation failed
    if (error.toLowerCase().contains('failed')) {
      return l10n.habitErrorMessageOperationFailed;
    }
    
    // Default
    return l10n.habitErrorMessageGeneral;
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
                    // Show error dialog if any
                    if (state.error != null && mounted) {
                      _showErrorDialog(
                        _getErrorTitle(state.error!),
                        _getErrorMessage(state.error!),
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
                        _buildRefreshableTab(
                          daily,
                          l10n,
                          'Daily',
                        ),
                        _buildRefreshableTab(
                          weekly,
                          l10n,
                          'Weekly',
                        ),
                        _buildRefreshableTab(
                          monthly,
                          l10n,
                          'Monthly',
                        ),
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
            builder: (context) => AddHabitDialog(
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

  Widget _buildRefreshableTab(
    List<Habit> habits,
    AppLocalizations l10n,
    String frequency,
  ) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.icon,
      child: habits.isEmpty
          // Needed so RefreshIndicator works even when empty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: _buildEmptyState(l10n, frequency),
                ),
              ],
            )
          : HabitList(habits: habits),
    );
  }
}