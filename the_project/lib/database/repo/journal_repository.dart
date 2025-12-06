import 'dart:convert';
import '../db_helper.dart';
import 'package:the_project/views/widgets/journal/journal_entry_model.dart';

class JournalRepository {
  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<int> createJournal({
    required int userId,
    required JournalEntryModel entry,
  }) async {
    final db = await DBHelper.database;

    final data = {
      'userId': userId,
      'date': entry.date.toIso8601String(),
      'time': _formatTime(entry.date),
      'mood': entry.moodImage,
      'title': entry.title,
      'text': entry.fullText,
      'voicePath': entry.voicePath,
      'backgroundImage': entry.backgroundImage,
      'fontFamily': entry.fontFamily,
      'textColor': entry.textColor,
      'fontSize': entry.fontSize,
      'attachedImages': entry.attachedImages != null
          ? jsonEncode(entry.attachedImages!.map((i) => i.toJson()).toList())
          : null,
      'stickers': entry.stickers != null
          ? jsonEncode(entry.stickers!.map((s) => s.toJson()).toList())
          : null,
    };

    return await db.insert('journals', data);
  }

  Future<int> updateJournal({
    required int journalId,
    required int userId,
    required JournalEntryModel entry,
  }) async {
    final db = await DBHelper.database;

    final data = {
      'userId': userId,
      'date': entry.date.toIso8601String(),
      'time': _formatTime(entry.date),
      'mood': entry.moodImage,
      'title': entry.title,
      'text': entry.fullText,
      'voicePath': entry.voicePath,
      'backgroundImage': entry.backgroundImage,
      'fontFamily': entry.fontFamily,
      'textColor': entry.textColor,
      'fontSize': entry.fontSize,
      'attachedImages': entry.attachedImages != null
          ? jsonEncode(entry.attachedImages!.map((i) => i.toJson()).toList())
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

  Future<int> deleteJournal(int journalId, int userId) async {
    final db = await DBHelper.database;
    return await db.delete(
      'journals',
      where: 'id = ? AND userId = ?',
      whereArgs: [journalId, userId],
    );
  }

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

  Future<List<JournalEntryModel>> getJournalsByDate({
    required int userId,
    required DateTime date,
  }) async {
    final db = await DBHelper.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final results = await db.query(
      'journals',
      where: 'userId = ? AND date >= ? AND date <= ?',
      whereArgs: [userId, startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'date DESC',
    );

    return results.map((row) => _mapToJournalEntry(row)).toList();
  }

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

  JournalEntryModel _mapToJournalEntry(Map<String, dynamic> row) {
    final date = DateTime.parse(row['date'] as String);

    List<ImageData>? attachedImages;
    if (row['attachedImages'] != null) {
      final decoded = jsonDecode(row['attachedImages'] as String);
      attachedImages = (decoded as List).map((i) => ImageData.fromJson(i)).toList();
    }

    List<StickerData>? stickers;
    if (row['stickers'] != null) {
      final decoded = jsonDecode(row['stickers'] as String) as List;
      stickers = decoded.map((s) => StickerData.fromJson(s)).toList();
    }

    return JournalEntryModel(
      id: row['id'] as int?,
      date: date, // No dateLabel needed - it's generated dynamically in UI
      moodImage: row['mood'] as String,
      title: row['title'] as String? ?? '',
      fullText: row['text'] as String? ?? '',
      voicePath: row['voicePath'] as String?,
      backgroundImage: row['backgroundImage'] as String?,
      fontFamily: row['fontFamily'] as String?,
      textColor: row['textColor'] as String?,
      fontSize: row['fontSize'] as double?,
      attachedImages: attachedImages,
      stickers: stickers,
    );
  }
}