import 'package:the_project/views/widgets/journal/journal_entry_model.dart';

enum JournalStatus { initial, loading, success, error }

class JournalState {
  final JournalStatus status;
  final List<JournalEntryModel> allJournals;
  final List<JournalEntryModel> filteredJournals;
  final String? selectedDateLabel;
  final int selectedMonth;
  final int selectedYear;
  final String? todayMood;
  final String? todayMoodLabel;
  final DateTime? todayMoodTime;
  final String? error;

  const JournalState({
    this.status = JournalStatus.initial,
    this.allJournals = const [],
    this.filteredJournals = const [],
    this.selectedDateLabel,
    int? selectedMonth,
    int? selectedYear,
    this.todayMood,
    this.todayMoodLabel,
    this.todayMoodTime,
    this.error,
  })  : selectedMonth = selectedMonth ?? 1,
        selectedYear = selectedYear ?? 2024;

  JournalState copyWith({
    JournalStatus? status,
    List<JournalEntryModel>? allJournals,
    List<JournalEntryModel>? filteredJournals,
    String? selectedDateLabel,
    int? selectedMonth,
    int? selectedYear,
    String? todayMood,
    String? todayMoodLabel,
    DateTime? todayMoodTime,
    String? error,
    bool clearDateLabel = false,
    bool clearMood = false,
  }) {
    return JournalState(
      status: status ?? this.status,
      allJournals: allJournals ?? this.allJournals,
      filteredJournals: filteredJournals ?? this.filteredJournals,
      selectedDateLabel: clearDateLabel ? null : (selectedDateLabel ?? this.selectedDateLabel),
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
      todayMood: clearMood ? null : (todayMood ?? this.todayMood),
      todayMoodLabel: clearMood ? null : (todayMoodLabel ?? this.todayMoodLabel),
      todayMoodTime: clearMood ? null : (todayMoodTime ?? this.todayMoodTime),
      error: error,
    );
  }

  /// Get count of entries by date label
  Map<String, int> get entriesByDate {
    final Map<String, int> map = {};
    for (var entry in allJournals) {
      if (entry.date.month == selectedMonth && entry.date.year == selectedYear) {
        map[entry.dateLabel] = (map[entry.dateLabel] ?? 0) + 1;
      }
    }
    return map;
  }
}