import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_project/l10n/app_localizations.dart';
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
    final now = DateTime.now();
    final cubit = context.read<JournalCubit>();
    
    cubit.loadJournalsByMonth(now.month, now.year).then((_) {
      final todayLabel = _formatDate(now);
      cubit.filterByDateLabel(todayLabel);
    });
  }

  String _formatDate(DateTime d) =>
      '${_weekdayName(d.weekday)}, ${_monthName(d.month)} ${d.day}';

  String _weekdayName(int w) => [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ][w - 1];

  String _monthName(int m) => [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][m - 1];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
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
                    child: _buildJournalList(state, l10n),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildJournalList(JournalState state, AppLocalizations l10n) {
    if (state.status == JournalStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.selectedDateLabel == null) {
      return Center(
        child: Text(
          l10n.journalSelectDay,
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
          l10n.journalNoEntries,
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
          child: Dismissible(
            key: Key(entry.id.toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.delete,
                color: AppColors.card,
                size: 28,
              ),
            ),
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(l10n.journalDeleteTitle),
                    content: Text(l10n.journalDeleteMessage),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(l10n.commonCancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                        child: Text(l10n.commonDelete),
                      ),
                    ],
                  );
                },
              );
            },
            onDismissed: (direction) async {
              if (entry.id != null) {
                final success = await context
                    .read<JournalCubit>()
                    .deleteJournal(entry.id!);
                
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.journalDeletedSuccessfully),
                      backgroundColor: AppColors.accentGreen,
                    ),
                  );
                }
              }
            },
            child: JournalEntryTemplate(
              title: entry.title,
              time: _formatTime(entry.date),
              moodImage: entry.moodImage,
              onTap: () => _openEditPage(entry),
            ),
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
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<JournalCubit>();
    
    if (initialDateLabel != null) {
      final selectedDate = _parseDateLabel(
        initialDateLabel,
        cubit.state.selectedYear,
      );
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      if (selectedDate.isAfter(today)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.journalCannotCreateFuture),
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
    final l10n = AppLocalizations.of(context)!;
    final result = await Navigator.of(context).push<JournalEntryModel>(
      MaterialPageRoute(
        builder: (_) => WriteJournalScreen.edit(existingEntry: entry),
      ),
    );

    if (result != null && mounted) {
      if (entry.id != null) {
        final success = await context.read<JournalCubit>().updateJournal(entry.id!, result);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.journalUpdatedSuccessfully),
              backgroundColor: AppColors.accentGreen,
            ),
          );
        }
      } else {
        await context.read<JournalCubit>().createJournal(result);
      }
    }
  }
}