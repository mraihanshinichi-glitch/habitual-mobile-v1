import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/category.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';
import '../../core/database/database_service.dart';

class SimpleBackupService {
  Future<Map<String, dynamic>> exportData() async {
    final databaseService = DatabaseService.instance;
    await databaseService.initialize();

    // Get all data from Hive boxes
    final categories = databaseService.categoriesBox.values.toList();
    final habits = databaseService.habitsBox.values.toList();
    final habitLogs = databaseService.habitLogsBox.values.toList();

    // Convert to JSON-serializable format
    final backup = {
      'version': '1.0.0',
      'timestamp': DateTime.now().toIso8601String(),
      'categories': categories
          .map(
            (category) => {
              'name': category.name,
              'color': category.color,
              'icon': category.icon,
              'createdAt': category.createdAt.toIso8601String(),
            },
          )
          .toList(),
      'habits': habits
          .map(
            (habit) => {
              'title': habit.title,
              'description': habit.description,
              'categoryId': habit.categoryId,
              'isArchived': habit.isArchived,
              'createdDate': habit.createdDate.toIso8601String(),
            },
          )
          .toList(),
      'habitLogs': habitLogs
          .map(
            (log) => {
              'habitId': log.habitId,
              'completionDate': log.completionDate.toIso8601String(),
            },
          )
          .toList(),
    };

    return backup;
  }

  Future<String?> createBackupFile() async {
    try {
      final backup = await exportData();
      final jsonString = const JsonEncoder.withIndent('  ').convert(backup);

      // Try multiple storage locations for maximum accessibility
      final fileName =
          'habitual_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      String? filePath;

      // Option 1: Downloads directory (most accessible)
      try {
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (await downloadsDir.exists()) {
          final file = File('${downloadsDir.path}/$fileName');
          await file.writeAsString(jsonString);
          filePath = file.path;
          print('DEBUG: Backup saved to Downloads: $filePath');
        }
      } catch (e) {
        print('DEBUG: Downloads directory not accessible: $e');
      }

      // Option 2: External storage directory
      if (filePath == null) {
        try {
          final directory = await getExternalStorageDirectory();
          if (directory != null) {
            final file = File('${directory.path}/$fileName');
            await file.writeAsString(jsonString);
            filePath = file.path;
            print('DEBUG: Backup saved to external storage: $filePath');
          }
        } catch (e) {
          print('DEBUG: External storage not accessible: $e');
        }
      }

      // Option 3: App documents directory (fallback)
      if (filePath == null) {
        try {
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/$fileName');
          await file.writeAsString(jsonString);
          filePath = file.path;
          print('DEBUG: Backup saved to app documents: $filePath');
        } catch (e) {
          print('DEBUG: App documents directory not accessible: $e');
        }
      }

      return filePath;
    } catch (e) {
      throw Exception('Failed to create backup: $e');
    }
  }

  Future<Map<String, dynamic>?> readBackupFromPath(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Backup file not found');
      }

      final jsonString = await file.readAsString();
      final backup = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate backup format
      if (!_isValidBackup(backup)) {
        throw Exception('Invalid backup file format');
      }

      return backup;
    } catch (e) {
      throw Exception('Failed to read backup file: $e');
    }
  }

  Future<bool> restoreFromBackup(Map<String, dynamic> backup) async {
    try {
      final databaseService = DatabaseService.instance;
      await databaseService.initialize();

      print('DEBUG: Starting restore process...');

      // Clear existing data
      await databaseService.categoriesBox.clear();
      await databaseService.habitsBox.clear();
      await databaseService.habitLogsBox.clear();

      print('DEBUG: Cleared existing data');

      // Restore categories using index-based approach
      final categories = backup['categories'] as List<dynamic>;
      for (int i = 0; i < categories.length; i++) {
        final categoryData = categories[i] as Map<String, dynamic>;
        final category = Category(
          name: categoryData['name'] as String,
          color: categoryData['color'] as int,
          icon: categoryData['icon'] as String,
          createdAt: DateTime.parse(categoryData['createdAt'] as String),
        );
        await databaseService.categoriesBox.add(
          category,
        ); // Use add() for consistency
      }

      print('DEBUG: Restored ${categories.length} categories');

      // Restore habits using index-based approach
      final habits = backup['habits'] as List<dynamic>;
      for (int i = 0; i < habits.length; i++) {
        final habitData = habits[i] as Map<String, dynamic>;
        final habit = Habit(
          title: habitData['title'] as String,
          description: habitData['description'] as String?,
          categoryId: habitData['categoryId'] as int,
          isArchived: habitData['isArchived'] as bool,
          createdDate: DateTime.parse(habitData['createdDate'] as String),
        );
        await databaseService.habitsBox.add(habit); // Use add() for consistency
      }

      print('DEBUG: Restored ${habits.length} habits');

      // Restore habit logs using index-based approach
      final habitLogs = backup['habitLogs'] as List<dynamic>;
      for (int i = 0; i < habitLogs.length; i++) {
        final logData = habitLogs[i] as Map<String, dynamic>;
        final log = HabitLog(
          habitId: logData['habitId'] as int,
          completionDate: DateTime.parse(logData['completionDate'] as String),
        );
        await databaseService.habitLogsBox.add(
          log,
        ); // Use add() for consistency
      }

      print('DEBUG: Restored ${habitLogs.length} habit logs');
      print('DEBUG: Restore completed successfully');

      return true;
    } catch (e) {
      print('DEBUG: Restore failed: $e');
      throw Exception('Failed to restore backup: $e');
    }
  }

  bool _isValidBackup(Map<String, dynamic> backup) {
    return backup.containsKey('version') &&
        backup.containsKey('categories') &&
        backup.containsKey('habits') &&
        backup.containsKey('habitLogs');
  }

  Future<Map<String, int>> getBackupStats(Map<String, dynamic> backup) async {
    return {
      'categories': (backup['categories'] as List).length,
      'habits': (backup['habits'] as List).length,
      'logs': (backup['habitLogs'] as List).length,
    };
  }

  Future<List<String>> getAvailableBackups() async {
    try {
      final backupFiles = <String>[];

      // Search in Downloads directory
      try {
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (await downloadsDir.exists()) {
          final files = await downloadsDir.list().toList();
          final downloadBackups = files
              .where(
                (file) =>
                    file.path.contains('habitual_backup') &&
                    file.path.endsWith('.json'),
              )
              .map((file) => file.path)
              .toList();
          backupFiles.addAll(downloadBackups);
          print('DEBUG: Found ${downloadBackups.length} backups in Downloads');
        }
      } catch (e) {
        print('DEBUG: Error reading Downloads directory: $e');
      }

      // Search in external storage directory
      try {
        final externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          final files = await externalDir.list().toList();
          final externalBackups = files
              .where(
                (file) =>
                    file.path.contains('habitual_backup') &&
                    file.path.endsWith('.json'),
              )
              .map((file) => file.path)
              .toList();
          backupFiles.addAll(externalBackups);
          print(
            'DEBUG: Found ${externalBackups.length} backups in external storage',
          );
        }
      } catch (e) {
        print('DEBUG: Error reading external storage: $e');
      }

      // Search in app documents directory
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final files = await appDir.list().toList();
        final appBackups = files
            .where(
              (file) =>
                  file.path.contains('habitual_backup') &&
                  file.path.endsWith('.json'),
            )
            .map((file) => file.path)
            .toList();
        backupFiles.addAll(appBackups);
        print('DEBUG: Found ${appBackups.length} backups in app documents');
      } catch (e) {
        print('DEBUG: Error reading app documents directory: $e');
      }

      // Remove duplicates and sort by modification time
      final uniqueBackups = backupFiles.toSet().toList();
      uniqueBackups.sort((a, b) {
        try {
          final fileA = File(a);
          final fileB = File(b);
          return fileB.lastModifiedSync().compareTo(fileA.lastModifiedSync());
        } catch (e) {
          return 0;
        }
      });

      print('DEBUG: Total unique backup files found: ${uniqueBackups.length}');
      return uniqueBackups;
    } catch (e) {
      print('DEBUG: Error getting available backups: $e');
      return [];
    }
  }

  Future<String?> pickBackupFile() async {
    try {
      // For now, return the most recent backup file
      final backups = await getAvailableBackups();
      if (backups.isNotEmpty) {
        // Sort by modification time (most recent first)
        backups.sort((a, b) {
          final fileA = File(a);
          final fileB = File(b);
          return fileB.lastModifiedSync().compareTo(fileA.lastModifiedSync());
        });
        return backups.first;
      }
      return null;
    } catch (e) {
      print('DEBUG: Error picking backup file: $e');
      return null;
    }
  }
}
