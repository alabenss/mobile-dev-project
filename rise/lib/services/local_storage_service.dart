// lib/services/local_storage_service.dart

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class LocalStorageService {
  // Singleton pattern
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static LocalStorageService get instance => _instance;

  /// Get the app's documents directory
  Future<Directory> getAppDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  /// Create necessary folders for the app
  Future<void> initializeFolders() async {
    try {
      final appDir = await getAppDirectory();
      
      // Create folders if they don't exist
      final folders = [
        'journals/images',
        'journals/voice',
        'journals/backgrounds',
        'user/profile_pictures',
      ];

      for (final folder in folders) {
        final dir = Directory('${appDir.path}/$folder');
        if (!await dir.exists()) {
          await dir.create(recursive: true);
          print('📁 Created folder: ${dir.path}');
        }
      }
    } catch (e) {
      print('❌ Error initializing folders: $e');
    }
  }

  /// Save an image file locally
  /// Returns the saved file path
  Future<String?> saveImage({
    required String sourcePath,
    required String category, // 'journal', 'profile', etc.
  }) async {
    try {
      final appDir = await getAppDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(sourcePath);
      final fileName = 'img_${timestamp}$extension';
      final targetPath = '${appDir.path}/journals/images/$fileName';

      // Copy file to app directory
      final sourceFile = File(sourcePath);
      final targetFile = await sourceFile.copy(targetPath);

      print('✅ Image saved: $targetPath');
      return targetFile.path;
    } catch (e) {
      print('❌ Error saving image: $e');
      return null;
    }
  }

  /// Save multiple images
  Future<List<String>> saveImages({
    required List<String> sourcePaths,
    required String category,
  }) async {
    final savedPaths = <String>[];
    
    for (final sourcePath in sourcePaths) {
      final savedPath = await saveImage(
        sourcePath: sourcePath,
        category: category,
      );
      if (savedPath != null) {
        savedPaths.add(savedPath);
      }
    }
    
    return savedPaths;
  }

  /// Save a voice recording file locally
  /// Returns the saved file path
  Future<String?> saveVoiceRecording({
    required String sourcePath,
  }) async {
    try {
      final appDir = await getAppDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(sourcePath);
      final fileName = 'voice_${timestamp}$extension';
      final targetPath = '${appDir.path}/journals/voice/$fileName';

      // Copy file to app directory
      final sourceFile = File(sourcePath);
      final targetFile = await sourceFile.copy(targetPath);

      print('✅ Voice recording saved: $targetPath');
      return targetFile.path;
    } catch (e) {
      print('❌ Error saving voice recording: $e');
      return null;
    }
  }

  /// Check if a file exists
  Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Delete a file
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        print('🗑️ File deleted: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error deleting file: $e');
      return false;
    }
  }

  /// Delete multiple files
  Future<void> deleteFiles(List<String> filePaths) async {
    for (final filePath in filePaths) {
      await deleteFile(filePath);
    }
  }

  /// Get total size of stored files (in MB)
  Future<double> getTotalStorageSize() async {
    try {
      final appDir = await getAppDirectory();
      final dir = Directory(appDir.path);
      
      int totalSize = 0;
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      
      // Convert to MB
      return totalSize / (1024 * 1024);
    } catch (e) {
      print('❌ Error calculating storage size: $e');
      return 0.0;
    }
  }

  /// Clean up old files (optional - for managing storage)
  Future<void> cleanupOldFiles({
    required int daysOld,
    required String category,
  }) async {
    try {
      final appDir = await getAppDirectory();
      final dir = Directory('${appDir.path}/journals/$category');
      
      if (!await dir.exists()) return;

      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      
      await for (final entity in dir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await entity.delete();
            print('🗑️ Cleaned up old file: ${entity.path}');
          }
        }
      }
    } catch (e) {
      print('❌ Error cleaning up files: $e');
    }
  }

  /// Export all user data (for backup feature - premium)
  Future<Directory?> createBackupFolder() async {
    try {
      final appDir = await getAppDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupDir = Directory('${appDir.path}/backups/backup_$timestamp');
      
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      
      return backupDir;
    } catch (e) {
      print('❌ Error creating backup folder: $e');
      return null;
    }
  }

  /// Copy file for backup
  Future<bool> backupFile(String sourcePath, String backupDirPath) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) return false;
      
      final fileName = path.basename(sourcePath);
      final targetPath = '$backupDirPath/$fileName';
      await sourceFile.copy(targetPath);
      
      return true;
    } catch (e) {
      print('❌ Error backing up file: $e');
      return false;
    }
  }
}