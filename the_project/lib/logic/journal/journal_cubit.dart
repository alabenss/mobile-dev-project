import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'journal_state.dart';
import '../../database/repo/journal_repository.dart';
import 'package:the_project/views/widgets/journal/journal_entry_model.dart';

class JournalCubit extends Cubit<JournalState> {
  final JournalRepository _repository;

  JournalCubit(this._repository) : super(JournalState(
    selectedMonth: DateTime.now().month,
    selectedYear: DateTime.now().year,
  ));

  /// Load journals for the logged-in user
  Future<void> loadJournals() async {
    emit(state.copyWith(status: JournalStatus.loading));

    try {
      final userId = await _getUserId();
      if (userId == null) {
        emit(state.copyWith(
          status: JournalStatus.error,
          error: 'User not logged in',
        ));
        return;
      }

      final journals = await _repository.getAllJournals(userId);
      emit(state.copyWith(
        status: JournalStatus.success,
        allJournals: journals,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: JournalStatus.error,
        error: e.toString(),
      ));
    }
  }

  /// Load journals for specific month
  Future<void> loadJournalsByMonth(int month, int year) async {
    // Store the current selected date before loading
    final previousSelectedDate = state.selectedDate;
    
    emit(state.copyWith(
      status: JournalStatus.loading,
      selectedMonth: month,
      selectedYear: year,
      // Keep the selected date during loading
    ));

    try {
      final userId = await _getUserId();
      if (userId == null) {
        emit(state.copyWith(
          status: JournalStatus.error,
          error: 'User not logged in',
        ));
        return;
      }

      final journals = await _repository.getJournalsByMonth(
        userId: userId,
        month: month,
        year: year,
      );

      // If we had a selected date, filter by it automatically
      if (previousSelectedDate != null) {
        final filtered = journals
            .where((j) => _isSameDay(j.date, previousSelectedDate))
            .toList();
        
        emit(state.copyWith(
          status: JournalStatus.success,
          allJournals: journals,
          filteredJournals: filtered,
          selectedDate: previousSelectedDate,
        ));
      } else {
        emit(state.copyWith(
          status: JournalStatus.success,
          allJournals: journals,
          filteredJournals: const [],
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: JournalStatus.error,
        error: e.toString(),
      ));
    }
  }

  /// Filter journals by date
  void filterByDate(DateTime date) {
    final filtered = state.allJournals
        .where((j) => _isSameDay(j.date, date))
        .toList();

    emit(state.copyWith(
      selectedDate: date,
      filteredJournals: filtered,
    ));
  }

  /// Clear date filter
  void clearDateFilter() {
    emit(state.copyWith(
      clearSelectedDate: true,
      filteredJournals: const [],
    ));
  }

  /// Create a new journal entry
  Future<bool> createJournal(JournalEntryModel entry) async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        emit(state.copyWith(error: 'User not logged in'));
        return false;
      }

      await _repository.createJournal(userId: userId, entry: entry);
      
      // Reload journals for current month (this will maintain the selected date)
      await loadJournalsByMonth(state.selectedMonth, state.selectedYear);
      
      return true;
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return false;
    }
  }

  /// Update an existing journal entry
  Future<bool> updateJournal(int journalId, JournalEntryModel entry) async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        emit(state.copyWith(error: 'User not logged in'));
        return false;
      }

      await _repository.updateJournal(
        journalId: journalId,
        userId: userId,
        entry: entry,
      );

      // Reload journals for current month (this will maintain the selected date)
      await loadJournalsByMonth(state.selectedMonth, state.selectedYear);
      
      return true;
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return false;
    }
  }

  /// Delete a journal entry
  Future<bool> deleteJournal(int journalId) async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        emit(state.copyWith(error: 'User not logged in'));
        return false;
      }

      await _repository.deleteJournal(journalId, userId);
      
      // Reload journals for current month (this will maintain the selected date)
      await loadJournalsByMonth(state.selectedMonth, state.selectedYear);
      
      return true;
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return false;
    }
  }

  /// Set today's mood
  void setTodayMood(String moodImage, String moodLabel) {
    if (moodImage.isEmpty) {
      emit(state.copyWith(clearMood: true));
    } else {
      emit(state.copyWith(
        todayMood: moodImage,
        todayMoodLabel: moodLabel,
        todayMoodTime: DateTime.now(),
      ));
    }
  }

  /// Get userId from SharedPreferences
  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(error: null));
  }

  /// Helper to check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}