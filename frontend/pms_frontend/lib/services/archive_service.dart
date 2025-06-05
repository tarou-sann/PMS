// Create frontend/pms_frontend/lib/services/archive_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class ArchiveItem {
  final String id;
  final String filename;
  final String filePath;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  ArchiveItem({
    required this.id,
    required this.filename,
    required this.filePath,
    required this.createdAt,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'filename': filename,
    'filePath': filePath,
    'createdAt': createdAt.toIso8601String(),
    'metadata': metadata,
  };

  factory ArchiveItem.fromJson(Map<String, dynamic> json) => ArchiveItem(
    id: json['id'],
    filename: json['filename'],
    filePath: json['filePath'],
    createdAt: DateTime.parse(json['createdAt']),
    metadata: json['metadata'],
  );

  bool get isExpired => DateTime.now().difference(createdAt).inDays >= 30;
}

class ArchiveService {
  static const String _archiveKey = 'backup_archives';
  static const String _archiveFolderName = 'PMS_Archives';

  // Get archives directory
  Future<Directory> _getArchiveDirectory() async {
    if (kIsWeb) {
      // For web, we'll use SharedPreferences to store file content
      throw UnsupportedError('File system not available on web');
    }
    
    final appDir = await getApplicationDocumentsDirectory();
    final archiveDir = Directory('${appDir.path}/$_archiveFolderName');
    
    if (!await archiveDir.exists()) {
      await archiveDir.create(recursive: true);
    }
    
    return archiveDir;
  }

  // Save backup to archives
  Future<ArchiveItem> saveBackupToArchive(String content, String filename, Map<String, dynamic> metadata) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    if (kIsWeb) {
      // For web, store in SharedPreferences
      return await _saveToWebStorage(id, filename, content, metadata);
    } else {
      // For desktop/mobile, save to file system
      return await _saveToFileSystem(id, filename, content, metadata);
    }
  }

  // Save to web storage (SharedPreferences)
  Future<ArchiveItem> _saveToWebStorage(String id, String filename, String content, Map<String, dynamic> metadata) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Store file content with unique key
    final contentKey = 'archive_content_$id';
    await prefs.setString(contentKey, content);
    
    final archiveItem = ArchiveItem(
      id: id,
      filename: filename,
      filePath: contentKey, // Use SharedPreferences key as path
      createdAt: DateTime.now(),
      metadata: metadata,
    );

    // Add to archives list
    await _addToArchivesList(archiveItem);
    
    return archiveItem;
  }

  // Save to file system
  Future<ArchiveItem> _saveToFileSystem(String id, String filename, String content, Map<String, dynamic> metadata) async {
    final archiveDir = await _getArchiveDirectory();
    final file = File('${archiveDir.path}/$filename');
    
    await file.writeAsString(content);
    
    final archiveItem = ArchiveItem(
      id: id,
      filename: filename,
      filePath: file.path,
      createdAt: DateTime.now(),
      metadata: metadata,
    );

    // Add to archives list
    await _addToArchivesList(archiveItem);
    
    return archiveItem;
  }

  // Add item to archives list
  Future<void> _addToArchivesList(ArchiveItem item) async {
    final archives = await getArchives();
    archives.add(item);
    await _saveArchivesList(archives);
  }

  // Get all archives
  Future<List<ArchiveItem>> getArchives() async {
    final prefs = await SharedPreferences.getInstance();
    final archivesJson = prefs.getString(_archiveKey);
    
    if (archivesJson == null) return [];
    
    final List<dynamic> archivesList = jsonDecode(archivesJson);
    return archivesList.map((json) => ArchiveItem.fromJson(json)).toList();
  }

  // Save archives list
  Future<void> _saveArchivesList(List<ArchiveItem> archives) async {
    final prefs = await SharedPreferences.getInstance();
    final archivesJson = jsonEncode(archives.map((item) => item.toJson()).toList());
    await prefs.setString(_archiveKey, archivesJson);
  }

  // Get archive content
  Future<String?> getArchiveContent(ArchiveItem archive) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(archive.filePath);
    } else {
      final file = File(archive.filePath);
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    }
  }

  // Delete archive
  Future<bool> deleteArchive(ArchiveItem archive) async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(archive.filePath);
      } else {
        final file = File(archive.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // Remove from archives list
      final archives = await getArchives();
      archives.removeWhere((item) => item.id == archive.id);
      await _saveArchivesList(archives);
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting archive: $e');
      }
      return false;
    }
  }

  // Clean expired archives (30+ days old)
  Future<int> cleanExpiredArchives() async {
    final archives = await getArchives();
    final expiredArchives = archives.where((archive) => archive.isExpired).toList();
    
    int deletedCount = 0;
    for (final archive in expiredArchives) {
      if (await deleteArchive(archive)) {
        deletedCount++;
      }
    }
    
    return deletedCount;
  }

  // Get storage size (approximate)
  Future<String> getStorageSize() async {
    final archives = await getArchives();
    int totalSize = 0;
    
    for (final archive in archives) {
      if (kIsWeb) {
        final content = await getArchiveContent(archive);
        totalSize += content?.length ?? 0;
      } else {
        final file = File(archive.filePath);
        if (await file.exists()) {
          totalSize += await file.length();
        }
      }
    }
    
    // Convert to readable format
    if (totalSize < 1024) return '$totalSize B';
    if (totalSize < 1024 * 1024) return '${(totalSize / 1024).toStringAsFixed(1)} KB';
    return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}