import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_project/views/themes/style_simple/colors.dart';
import '../../themes/style_simple/app_background.dart';
import '../../widgets/journal/journal_entry_model.dart';
import '../../widgets/journal/mood_card.dart';
import '../../widgets/journal/month_year_selector.dart';
import '../../widgets/journal/calendar_row.dart';
import '../../widgets/journal/journal_entry_template.dart';
import 'package:the_project/logic/journal/journal_cubit.dart';
import 'package:the_project/logic/journal/journal_state.dart';
import 'write_journal_screen.dart';

class JournalingScreen extends StatefulWidget {
  const JournalingScreen({super.key});

  @override
  State<JournalingScreen> createState() => _JournalingScreenState();
}

class _JournalingScreenState extends State<JournalingScreen> {
  @override
  void initState() {
    super.initState();
    // Load journals when screen opens
    context.read<JournalCubit>().loadJournalsByMonth(
      DateTime.now().month,
      DateTime.now().year,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () => _openWritePage(),
        backgroundColor: AppColors.icon,
        child: const Icon(Icons.add, color: AppColors.card, size: 28),
      ),
      body: AppBackground(
        child: BlocConsumer<JournalCubit, JournalState>(
          listener: (context, state) {
            // Show error if any
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: AppColors.error,
                ),
              );
              context.read<JournalCubit>().clearError();
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // MoodCard now manages its own state
                  const MoodCard(),
                  const SizedBox(height: 20),
                  
                  MonthYearSelector(
                    selectedMonth: state.selectedMonth,
                    selectedYear: state.selectedYear,
                    onChanged: (month, year) {
                      context.read<JournalCubit>().loadJournalsByMonth(
                        month,
                        year,
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  CalendarRow(
                    month: state.selectedMonth,
                    year: state.selectedYear,
                    selectedDateLabel: state.selectedDateLabel,
                    entriesByDate: state.entriesByDate,
                    onDateTap: (dateLabel) {
                      context.read<JournalCubit>().filterByDateLabel(dateLabel);
                    },
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Expanded(
                    child: _buildJournalList(state),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildJournalList(JournalState state) {
    if (state.status == JournalStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.selectedDateLabel == null) {
      return Center(
        child: Text(
          'Select a day to view journals',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
      );
    }

    if (state.filteredJournals.isEmpty) {
      return Center(
        child: Text(
          'No journals for this day',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: state.filteredJournals.length,
      itemBuilder: (context, index) {
        final entry = state.filteredJournals[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: JournalEntryTemplate(
            title: entry.title,
            time: _formatTime(entry.date),
            moodImage: entry.moodImage,
            onTap: () => _openEditPage(entry),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  Future<void> _openWritePage({String? initialDateLabel}) async {
    final cubit = context.read<JournalCubit>();
    
    // Verify the date is not in the future
    if (initialDateLabel != null) {
      final selectedDate = _parseDateLabel(
        initialDateLabel,
        cubit.state.selectedYear,
      );
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      if (selectedDate.isAfter(today)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot create journal for future dates'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    final result = await Navigator.of(context).push<JournalEntryModel>(
      MaterialPageRoute(
        builder: (_) => WriteJournalScreen(
          initialDateLabel: initialDateLabel ?? cubit.state.selectedDateLabel,
          initialMonth: cubit.state.selectedMonth,
          initialYear: cubit.state.selectedYear,
        ),
      ),
    );

    if (result != null && mounted) {
      await cubit.createJournal(result);
    }
  }

  DateTime _parseDateLabel(String label, int year) {
    final parts = label.split(', ');
    if (parts.length != 2) return DateTime.now();
    
    final dateParts = parts[1].split(' ');
    if (dateParts.length != 2) return DateTime.now();
    
    final monthStr = dateParts[0];
    final day = int.tryParse(dateParts[1]) ?? 1;
    
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = months.indexOf(monthStr) + 1;
    
    return DateTime(year, month, day);
  }

  Future<void> _openEditPage(JournalEntryModel entry) async {
    final result = await Navigator.of(context).push<JournalEntryModel>(
      MaterialPageRoute(
        builder: (_) => WriteJournalScreen.edit(existingEntry: entry),
      ),
    );

    if (result != null && mounted) {
      // Check if the entry has an ID
      if (entry.id != null) {
        // UPDATE the existing journal
        final success = await context.read<JournalCubit>().updateJournal(entry.id!, result);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Journal updated successfully'),
              backgroundColor: AppColors.accentGreen,
            ),
          );
        }
      } else {
        // Fallback: create new if somehow no ID exists
        await context.read<JournalCubit>().createJournal(result);
      }
    }
  }
}

