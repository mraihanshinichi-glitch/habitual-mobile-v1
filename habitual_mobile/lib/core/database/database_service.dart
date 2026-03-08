import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../shared/models/category.dart';
import '../../shared/models/habit.dart';
import '../../shared/models/habit_log.dart';
import '../../shared/models/habit_frequency.dart';
import '../../shared/models/user_streak.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static bool _initialized = false;

  DatabaseService._();

  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      print('DEBUG initialize: Starting Hive initialization');
      
      // Get application documents directory explicitly
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String path = appDocDir.path;
      print('DEBUG initialize: App documents path: $path');
      
      // Initialize Hive with explicit path
      await Hive.initFlutter(path);
      print('DEBUG initialize: Hive initialized successfully');
      
      // Register adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(CategoryAdapter());
        print('DEBUG initialize: CategoryAdapter registered');
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(HabitAdapter());
        print('DEBUG initialize: HabitAdapter registered');
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(HabitLogAdapter());
        print('DEBUG initialize: HabitLogAdapter registered');
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(HabitFrequencyAdapter());
        print('DEBUG initialize: HabitFrequencyAdapter registered');
      }
      if (!Hive.isAdapterRegistered(5)) {
        Hive.registerAdapter(UserStreakAdapter());
        print('DEBUG initialize: UserStreakAdapter registered');
      }
      
      // Open boxes
      if (!Hive.isBoxOpen('categories')) {
        await Hive.openBox<Category>('categories');
        print('DEBUG initialize: Categories box opened');
      }
      if (!Hive.isBoxOpen('habits')) {
        await Hive.openBox<Habit>('habits');
        print('DEBUG initialize: Habits box opened');
      }
      if (!Hive.isBoxOpen('habit_logs')) {
        await Hive.openBox<HabitLog>('habit_logs');
        print('DEBUG initialize: Habit logs box opened');
      }
      if (!Hive.isBoxOpen('user_streak')) {
        await Hive.openBox<UserStreak>('user_streak');
        print('DEBUG initialize: User streak box opened');
      }
      
      // TEMPORARY FIX: Clear invalid habit logs
      await _cleanupInvalidHabitLogs();
      
      _initialized = true;
      print('DEBUG initialize: Database initialization completed successfully');
    } catch (e, stackTrace) {
      print('DEBUG initialize: Error during initialization: $e');
      print('DEBUG initialize: Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  Future<void> _cleanupInvalidHabitLogs() async {
    try {
      final habitsBox = Hive.box<Habit>('habits');
      final logsBox = Hive.box<HabitLog>('habit_logs');
      
      print('DEBUG _cleanupInvalidHabitLogs: Checking ${logsBox.length} logs against ${habitsBox.length} habits');
      
      // Get all valid habit indices
      final validHabitIndices = <int>{};
      for (int i = 0; i < habitsBox.length; i++) {
        if (habitsBox.getAt(i) != null) {
          validHabitIndices.add(i);
        }
      }
      
      print('DEBUG _cleanupInvalidHabitLogs: Valid habit indices: $validHabitIndices');
      
      // Remove logs for non-existent habits
      final logsToRemove = <int>[];
      for (int i = 0; i < logsBox.length; i++) {
        final log = logsBox.getAt(i);
        if (log != null && !validHabitIndices.contains(log.habitId)) {
          logsToRemove.add(i);
          print('DEBUG _cleanupInvalidHabitLogs: Marking log for removal - habitId: ${log.habitId} (invalid)');
        }
      }
      
      // Remove invalid logs in reverse order to maintain indices
      for (int i = logsToRemove.length - 1; i >= 0; i--) {
        await logsBox.deleteAt(logsToRemove[i]);
        print('DEBUG _cleanupInvalidHabitLogs: Removed invalid log at index ${logsToRemove[i]}');
      }
      
      print('DEBUG _cleanupInvalidHabitLogs: Cleanup completed. Removed ${logsToRemove.length} invalid logs');
    } catch (e) {
      print('DEBUG _cleanupInvalidHabitLogs: Error during cleanup: $e');
    }
  }

  Box<Category> get categoriesBox => Hive.box<Category>('categories');
  Box<Habit> get habitsBox => Hive.box<Habit>('habits');
  Box<HabitLog> get habitLogsBox => Hive.box<HabitLog>('habit_logs');
  Box<UserStreak> get userStreakBox => Hive.box<UserStreak>('user_streak');

  Future<void> seedDefaultCategories() async {
    await initialize();
    
    if (categoriesBox.isNotEmpty) return; // Already seeded

    final defaultCategories = [
      Category(name: 'Kesehatan', color: 0xFF4CAF50, icon: 'favorite'),
      Category(name: 'Belajar', color: 0xFF2196F3, icon: 'school'),
      Category(name: 'Kerja', color: 0xFFFF9800, icon: 'work'),
      Category(name: 'Olahraga', color: 0xFFF44336, icon: 'fitness_center'),
      Category(name: 'Hobi', color: 0xFF9C27B0, icon: 'palette'),
    ];

    print('DEBUG seedDefaultCategories: Seeding ${defaultCategories.length} categories');
    for (int i = 0; i < defaultCategories.length; i++) {
      final index = await categoriesBox.add(defaultCategories[i]);
      print('DEBUG seedDefaultCategories: Added "${defaultCategories[i].name}" at index $index');
    }
  }

  Future<void> resetDatabase() async {
    await initialize();
    
    print('DEBUG resetDatabase: Clearing all data');
    await categoriesBox.clear();
    await habitsBox.clear();
    await habitLogsBox.clear();
    
    // Re-seed categories
    await seedDefaultCategories();
  }

  Future<void> migrateDatabase() async {
    await initialize();
    
    print('DEBUG migrateDatabase: Starting database migration');
    
    // Migrate existing habits to handle new fields
    final habitsBox = this.habitsBox;
    final habitsToMigrate = <int, Habit>{};
    
    for (int i = 0; i < habitsBox.length; i++) {
      try {
        final habit = habitsBox.getAt(i);
        if (habit != null) {
          // Check if habit needs migration (has null frequency)
          if (habit.frequency == null) {
            print('DEBUG migrateDatabase: Migrating habit at index $i: ${habit.title}');
            
            // Create migrated habit with default values
            final migratedHabit = Habit(
              title: habit.title,
              description: habit.description,
              categoryId: habit.categoryId,
              isArchived: habit.isArchived,
              createdDate: habit.createdDate,
              frequency: HabitFrequency.daily, // Default frequency
              timerDurationMinutes: null,
              hasNotification: false,
              notificationTime: null,
            );
            
            habitsToMigrate[i] = migratedHabit;
          }
        }
      } catch (e) {
        print('DEBUG migrateDatabase: Error reading habit at index $i: $e');
        // Skip corrupted entries
      }
    }
    
    // Apply migrations
    for (final entry in habitsToMigrate.entries) {
      try {
        await habitsBox.putAt(entry.key, entry.value);
        print('DEBUG migrateDatabase: Successfully migrated habit at index ${entry.key}');
      } catch (e) {
        print('DEBUG migrateDatabase: Error migrating habit at index ${entry.key}: $e');
      }
    }
    
    print('DEBUG migrateDatabase: Migration completed. Migrated ${habitsToMigrate.length} habits');
  }

  Future<void> close() async {
    await Hive.close();
    _initialized = false;
  }
}