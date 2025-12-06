import 'package:the_project/views/widgets/journal/journal_entry_model.dart';

enum JournalStatus { initial, loading, success, error }

class JournalState {
  final JournalStatus status;
  final List<JournalEntryModel> allJournals;
  final List<JournalEntryModel> filteredJournals;
  final DateTime? selectedDate;
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
    this.selectedDate,
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
    DateTime? selectedDate,
    int? selectedMonth,
    int? selectedYear,
    String? todayMood,
    String? todayMoodLabel,
    DateTime? todayMoodTime,
    String? error,
    bool clearSelectedDate = false,
    bool clearMood = false,
  }) {
    return JournalState(
      status: status ?? this.status,
      allJournals: allJournals ?? this.allJournals,
      filteredJournals: filteredJournals ?? this.filteredJournals,
      selectedDate: clearSelectedDate ? null : (selectedDate ?? this.selectedDate),
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
      todayMood: clearMood ? null : (todayMood ?? this.todayMood),
      todayMoodLabel: clearMood ? null : (todayMoodLabel ?? this.todayMoodLabel),
      todayMoodTime: clearMood ? null : (todayMoodTime ?? this.todayMoodTime),
      error: error,
    );
  }

  /// Get count of entries by date (returns map with date keys: YYYY-MM-DD)
  Map<String, int> get entriesByDate {
    final Map<String, int> map = {};
    for (var entry in allJournals) {
      if (entry.date.month == selectedMonth && entry.date.year == selectedYear) {
        final dateKey = entry.dateKey;
        map[dateKey] = (map[dateKey] ?? 0) + 1;
      }
    }
    return map;
  }
}