import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:the_project/config/api_config.dart';
import 'package:the_project/views/widgets/journal/journal_entry_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JournalRepository {
  
  Future<int?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<int> createJournal({
    required int userId,
    required JournalEntryModel entry,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.BASE_URL}${ApiConfig.JOURNALS_ADD}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
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
          'attachedImages': entry.attachedImages?.map((i) => i.toJson()).toList(),
          'stickers': entry.stickers?.map((s) => s.toJson()).toList(),
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['journalId'];
      } else {
        throw Exception('Failed to create journal');
      }
    } catch (e) {
      print('Error creating journal: $e');
      rethrow;
    }
  }

  Future<int> updateJournal({
    required int journalId,
    required int userId,
    required JournalEntryModel entry,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.BASE_URL}${ApiConfig.JOURNALS_UPDATE}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': journalId,
          'userId': userId,
          'text': entry.fullText,
          'title': entry.title,
          'mood': entry.moodImage,
          'backgroundImage': entry.backgroundImage,
          'fontFamily': entry.fontFamily,
          'textColor': entry.textColor,
          'fontSize': entry.fontSize,
          'attachedImages': entry.attachedImages?.map((i) => i.toJson()).toList(),
          'stickers': entry.stickers?.map((s) => s.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        return 1;
      } else {
        throw Exception('Failed to update journal');
      }
    } catch (e) {
      print('Error updating journal: $e');
      rethrow;
    }
  }

  // ADD THIS METHOD - Missing in your current code
  Future<int> deleteJournal(int journalId, int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.BASE_URL}${ApiConfig.JOURNALS_DELETE}?id=$journalId&userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return 1;
      } else {
        throw Exception('Failed to delete journal');
      }
    } catch (e) {
      print('Error deleting journal: $e');
      rethrow;
    }
  }

  Future<List<JournalEntryModel>> getAllJournals(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.BASE_URL}${ApiConfig.JOURNALS_GET}?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final journals = data['journals'] as List;
        return journals.map((j) => _mapToJournalEntry(j)).toList();
      } else {
        throw Exception('Failed to load journals');
      }
    } catch (e) {
      print('Error loading journals: $e');
      return [];
    }
  }

  // ADD THIS METHOD - Missing in your current code
  Future<List<JournalEntryModel>> getJournalsByMonth({
    required int userId,
    required int month,
    required int year,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.BASE_URL}${ApiConfig.JOURNALS_GET}?userId=$userId&month=$month&year=$year'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final journals = data['journals'] as List;
        
        // Filter by month on client side (in case backend doesn't filter)
        return journals
            .map((j) => _mapToJournalEntry(j))
            .where((journal) {
              return journal.date.month == month && journal.date.year == year;
            })
            .toList();
      } else {
        throw Exception('Failed to load journals');
      }
    } catch (e) {
      print('Error loading journals by month: $e');
      return [];
    }
  }

  // ADD THIS METHOD - Missing in your current code
  Future<List<JournalEntryModel>> getJournalsByDate({
    required int userId,
    required DateTime date,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.BASE_URL}${ApiConfig.JOURNALS_GET}?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final journals = data['journals'] as List;
        
        // Filter by date on client side
        return journals
            .map((j) => _mapToJournalEntry(j))
            .where((journal) {
              return _isSameDay(journal.date, date);
            })
            .toList();
      } else {
        throw Exception('Failed to load journals');
      }
    } catch (e) {
      print('Error loading journals by date: $e');
      return [];
    }
  }

  // ADD THIS METHOD - Missing in your current code
  Future<JournalEntryModel?> getJournalById(int journalId, int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.BASE_URL}${ApiConfig.JOURNALS_GET}?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final journals = data['journals'] as List;
        
        // Find specific journal
        final journal = journals.firstWhere(
          (j) => j['id'] == journalId,
          orElse: () => null,
        );
        
        if (journal == null) return null;
        return _mapToJournalEntry(journal);
      } else {
        throw Exception('Failed to load journal');
      }
    } catch (e) {
      print('Error loading journal by id: $e');
      return null;
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  JournalEntryModel _mapToJournalEntry(Map<String, dynamic> row) {
    final date = DateTime.parse(row['date']);

    List<ImageData>? attachedImages;
    if (row['attached_images'] != null) {
      final decoded = row['attached_images'] is String 
          ? jsonDecode(row['attached_images']) 
          : row['attached_images'];
      attachedImages = (decoded as List).map((i) => ImageData.fromJson(i)).toList();
    }

    List<StickerData>? stickers;
    if (row['stickers'] != null) {
      final decoded = row['stickers'] is String 
          ? jsonDecode(row['stickers']) 
          : row['stickers'];
      stickers = (decoded as List).map((s) => StickerData.fromJson(s)).toList();
    }

    return JournalEntryModel(
      id: row['id'],
      date: date,
      moodImage: row['mood'] ?? '',
      title: row['title'] ?? '',
      fullText: row['text'] ?? '',
      voicePath: row['voice_path'],
      backgroundImage: row['background_image'],
      fontFamily: row['font_family'],
      textColor: row['text_color'],
      fontSize: row['font_size']?.toDouble(),
      attachedImages: attachedImages,
      stickers: stickers,
    );
  }
}