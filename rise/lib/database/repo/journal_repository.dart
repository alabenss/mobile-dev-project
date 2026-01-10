import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:the_project/config/api_config.dart';
import 'package:the_project/views/widgets/journal/journal_entry_model.dart';
import 'package:the_project/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JournalRepository {
  final LocalStorageService _storage = LocalStorageService.instance;

  Future<int?> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<int?> createJournal({
    required int userId,
    required JournalEntryModel entry,
  }) async {
    try {
      // 1. Save images locally and get their paths
      List<ImageData>? savedImages;
      if (entry.attachedImages != null && entry.attachedImages!.isNotEmpty) {
        savedImages = [];
        for (final img in entry.attachedImages!) {
          // If it's a new image (from gallery), save it locally
          final savedPath = await _storage.saveImage(
            sourcePath: img.path,
            category: 'journal',
          );
          if (savedPath != null) {
            savedImages.add(ImageData(
              path: savedPath, // Use the saved local path
              x: img.x,
              y: img.y,
            ));
          }
        }
      }

      // 2. Save voice recording locally if exists
      String? savedVoicePath;
      if (entry.voicePath != null && entry.voicePath!.isNotEmpty) {
        savedVoicePath = await _storage.saveVoiceRecording(
          sourcePath: entry.voicePath!,
        );
      }

      // 3. Send to backend with local file paths
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
          'voicePath': savedVoicePath, // Local path
          'backgroundImage': entry.backgroundImage,
          'fontFamily': entry.fontFamily,
          'textColor': entry.textColor,
          'fontSize': entry.fontSize,
          'attachedImages': savedImages?.map((i) => i.toJson()).toList(),
          'stickers': entry.stickers?.map((s) => s.toJson()).toList(),
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Journal created with local files');
        return data['journalId'];
      } else {
        throw Exception('Failed to create journal');
      }
    } catch (e) {
      print('❌ Error creating journal: $e');
      rethrow;
    }
  }

  Future<int?> updateJournal({
    required int journalId,
    required int userId,
    required JournalEntryModel entry,
  }) async {
    try {
      // Process images - save new ones, keep existing ones
      List<ImageData>? processedImages;
      if (entry.attachedImages != null && entry.attachedImages!.isNotEmpty) {
        processedImages = [];
        for (final img in entry.attachedImages!) {
          // Check if it's a new image (not yet saved locally)
          if (!img.path.contains('/data/user/')) {
            // It's a new image from gallery
            final savedPath = await _storage.saveImage(
              sourcePath: img.path,
              category: 'journal',
            );
            if (savedPath != null) {
              processedImages.add(ImageData(
                path: savedPath,
                x: img.x,
                y: img.y,
              ));
            }
          } else {
            // It's already a local path, keep it
            processedImages.add(img);
          }
        }
      }

      // Process voice recording
      String? processedVoicePath = entry.voicePath;
      if (entry.voicePath != null &&
          entry.voicePath!.isNotEmpty &&
          !entry.voicePath!.contains('/data/user/')) {
        // It's a new recording, save it
        processedVoicePath = await _storage.saveVoiceRecording(
          sourcePath: entry.voicePath!,
        );
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.BASE_URL}${ApiConfig.JOURNALS_UPDATE}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': journalId,
          'userId': userId,
          'text': entry.fullText,
          'title': entry.title,
          'mood': entry.moodImage,
          'voicePath': processedVoicePath, // ✅ FIXED: Now included!
          'backgroundImage': entry.backgroundImage,
          'fontFamily': entry.fontFamily,
          'textColor': entry.textColor,
          'fontSize': entry.fontSize,
          'attachedImages': processedImages?.map((i) => i.toJson()).toList(),
          'stickers': entry.stickers?.map((s) => s.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Journal updated with local files');
        return 1;
      } else {
        throw Exception('Failed to update journal');
      }
    } catch (e) {
      print('❌ Error updating journal: $e');
      rethrow;
    }
  }

  Future<int?> deleteJournal(int journalId, int userId) async {
    try {
      // First, get the journal to find associated files
      final journals = await getAllJournals(userId);
      final journal = journals.firstWhere(
        (j) => j.id == journalId,
        orElse: () => throw Exception('Journal not found'),
      );

      // Delete associated local files
      if (journal.attachedImages != null) {
        for (final img in journal.attachedImages!) {
          await _storage.deleteFile(img.path);
        }
      }

      if (journal.voicePath != null && journal.voicePath!.isNotEmpty) {
        await _storage.deleteFile(journal.voicePath!);
      }

      // Delete from database
      final response = await http.delete(
        Uri.parse(
            '${ApiConfig.BASE_URL}${ApiConfig.JOURNALS_DELETE}?id=$journalId&userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('✅ Journal and associated files deleted');
        return 1;
      } else {
        throw Exception('Failed to delete journal');
      }
    } catch (e) {
      print('❌ Error deleting journal: $e');
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

        // Verify local files exist
        final validJournals = <JournalEntryModel>[];

        for (final j in journals) {
          final entry = _mapToJournalEntry(j);

          // Check and filter valid images
          List<ImageData>? validImages;
          if (entry.attachedImages != null && entry.attachedImages!.isNotEmpty) {
            validImages = [];
            for (final img in entry.attachedImages!) {
              if (await _storage.fileExists(img.path)) {
                validImages.add(img);
              }
            }
          }

          // Check voice file validity
          String? validVoicePath = entry.voicePath;
          if (entry.voicePath != null && entry.voicePath!.isNotEmpty) {
            if (!await _storage.fileExists(entry.voicePath!)) {
              validVoicePath = null;
            }
          }

          // Create a new instance with validated data
          final validatedEntry = JournalEntryModel(
            id: entry.id,
            date: entry.date,
            moodImage: entry.moodImage,
            title: entry.title,
            fullText: entry.fullText,
            voicePath: validVoicePath, // Use validated voice path
            backgroundImage: entry.backgroundImage,
            fontFamily: entry.fontFamily,
            textColor: entry.textColor,
            fontSize: entry.fontSize,
            attachedImages: validImages, // Use validated images
            stickers: entry.stickers,
          );

          validJournals.add(validatedEntry);
        }

        return validJournals;
      } else {
        throw Exception('Failed to load journals');
      }
    } catch (e) {
      print('❌ Error loading journals: $e');
      return [];
    }
  }

  Future<List<JournalEntryModel>> getJournalsByMonth({
    required int userId,
    required int month,
    required int year,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
            '${ApiConfig.BASE_URL}${ApiConfig.JOURNALS_GET}?userId=$userId&month=$month&year=$year'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final journals = data['journals'] as List;
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
      print('❌ Error loading journals by month: $e');
      return [];
    }
  }

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
        return journals
            .map((j) => _mapToJournalEntry(j))
            .where((journal) => _isSameDay(journal.date, date))
            .toList();
      } else {
        throw Exception('Failed to load journals');
      }
    } catch (e) {
      print('❌ Error loading journals by date: $e');
      return [];
    }
  }

  Future<JournalEntryModel?> getJournalById(int journalId, int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.BASE_URL}${ApiConfig.JOURNALS_GET}?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final journals = data['journals'] as List;
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
      print('❌ Error loading journal by id: $e');
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
      attachedImages =
          (decoded as List).map((i) => ImageData.fromJson(i)).toList();
    }

    List<StickerData>? stickers;
    if (row['stickers'] != null) {
      final decoded = row['stickers'] is String
          ? jsonDecode(row['stickers'])
          : row['stickers'];
      stickers =
          (decoded as List).map((s) => StickerData.fromJson(s)).toList();
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