import 'dart:convert';
import '../db_helper.dart';
import 'package:the_project/views/widgets/journal/journal_entry_model.dart';

class JournalRepository {
  /// Format time as HH:mm (24-hour format)
  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Create a new journal entry
  Future<int> createJournal({
    required int userId,
    required JournalEntryModel entry,
  }) async {
    final db = await DBHelper.database;
    
    final data = {
      'userId': userId,
      'date': entry.date.toIso8601String(),
      'time': _formatTime(entry.date), // HH:mm format
      'mood': entry.moodImage,
      'title': entry.title,
      'text': entry.fullText,
      'backgroundImage': entry.backgroundImage,
      'fontFamily': entry.fontFamily,
      'textColor': entry.textColor,
      'fontSize': entry.fontSize,
      'attachedImages': entry.attachedImages != null 
          ? jsonEncode(entry.attachedImages) 
          : null,
      'stickers': entry.stickers != null 
          ? jsonEncode(entry.stickers!.map((s) => s.toJson()).toList())
          : null,
    };

    return await db.insert('journals', data);
  }

  /// Update an existing journal entry
  Future<int> updateJournal({
    required int journalId,
    required int userId,
    required JournalEntryModel entry,
  }) async {
    final db = await DBHelper.database;
    
    final data = {
      'userId': userId,
      'date': entry.date.toIso8601String(),
      'time': _formatTime(entry.date), // HH:mm format
      'mood': entry.moodImage,
      'title': entry.title,
      'text': entry.fullText,
      'backgroundImage': entry.backgroundImage,
      'fontFamily': entry.fontFamily,
      'textColor': entry.textColor,
      'fontSize': entry.fontSize,
      'attachedImages': entry.attachedImages != null 
          ? jsonEncode(entry.attachedImages) 
          : null,
      'stickers': entry.stickers != null 
          ? jsonEncode(entry.stickers!.map((s) => s.toJson()).toList())
          : null,
    };

    return await db.update(
      'journals',
      data,
      where: 'id = ? AND userId = ?',
      whereArgs: [journalId, userId],
    );
  }

  /// Delete a journal entry
  Future<int> deleteJournal(int journalId, int userId) async {
    final db = await DBHelper.database;
    return await db.delete(
      'journals',
      where: 'id = ? AND userId = ?',
      whereArgs: [journalId, userId],
    );
  }

  /// Get all journals for a user
  Future<List<JournalEntryModel>> getAllJournals(int userId) async {
    final db = await DBHelper.database;
    final results = await db.query(
      'journals',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    return results.map((row) => _mapToJournalEntry(row)).toList();
  }

  /// Get journals for a specific month and year
  Future<List<JournalEntryModel>> getJournalsByMonth({
    required int userId,
    required int month,
    required int year,
  }) async {
    final db = await DBHelper.database;
    final startDate = DateTime(year, month, 1).toIso8601String();
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59).toIso8601String();

    final results = await db.query(
      'journals',
      where: 'userId = ? AND date >= ? AND date <= ?',
      whereArgs: [userId, startDate, endDate],
      orderBy: 'date DESC',
    );

    return results.map((row) => _mapToJournalEntry(row)).toList();
  }

  /// Get journals for a specific date label
  Future<List<JournalEntryModel>> getJournalsByDateLabel({
    required int userId,
    required String dateLabel,
  }) async {
    final allJournals = await getAllJournals(userId);
    return allJournals.where((j) => j.dateLabel == dateLabel).toList();
  }

  /// Get a single journal by ID
  Future<JournalEntryModel?> getJournalById(int journalId, int userId) async {
    final db = await DBHelper.database;
    final results = await db.query(
      'journals',
      where: 'id = ? AND userId = ?',
      whereArgs: [journalId, userId],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return _mapToJournalEntry(results.first);
  }

  /// Convert database row to JournalEntryModel
  JournalEntryModel _mapToJournalEntry(Map<String, dynamic> row) {
    final date = DateTime.parse(row['date'] as String);
    final dateLabel = _formatDateLabel(date);

    List<String>? attachedImages;
    if (row['attachedImages'] != null) {
      final decoded = jsonDecode(row['attachedImages'] as String);
      attachedImages = List<String>.from(decoded);
    }

    List<StickerData>? stickers;
    if (row['stickers'] != null) {
      final decoded = jsonDecode(row['stickers'] as String) as List;
      stickers = decoded.map((s) => StickerData.fromJson(s)).toList();
    }

    return JournalEntryModel(
      id: row['id'] as int?, // IMPORTANT: Include the ID
      dateLabel: dateLabel,
      date: date,
      moodImage: row['mood'] as String,
      title: row['title'] as String? ?? '',
      fullText: row['text'] as String? ?? '',
      backgroundImage: row['backgroundImage'] as String?,
      fontFamily: row['fontFamily'] as String?,
      textColor: row['textColor'] as String?,
      fontSize: row['fontSize'] as double?,
      attachedImages: attachedImages,
      stickers: stickers,
    );
  }

  /// Format date to label (e.g., "Wednesday, Oct 15")
  String _formatDateLabel(DateTime date) {
    return '${_getWeekdayFull(date.weekday)}, ${_getMonthShort(date.month)} ${date.day}';
  }

  String _getWeekdayFull(int w) => [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ][w - 1];

  String _getMonthShort(int m) => [
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
}