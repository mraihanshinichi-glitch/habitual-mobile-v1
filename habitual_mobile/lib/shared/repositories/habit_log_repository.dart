import '../../core/database/database_service.dart';
import '../models/habit_log.dart';
import '../models/habit.dart';
import '../models/category.dart';

class HabitLogRepository {
  final DatabaseService _databaseService = DatabaseService.instance;

  Future<List<HabitLog>> getLogsByHabitId(int habitId) async {
    await _databaseService.initialize();
    final logs = _databaseService.habitLogsBox.values.toList();
    return logs.where((log) => log.habitId == habitId).toList()
      ..sort((a, b) => b.completionDate.compareTo(a.completionDate));
  }

  Future<HabitLog?> getLogByHabitAndDate(int habitId, DateTime date) async {
    await _databaseService.initialize();
    final startOfDay = DateTime(date.year, date.month, date.day);

    final logs = _databaseService.habitLogsBox.values.toList();
    print(
      'DEBUG: Searching through ${logs.length} logs for habitId: $habitId on date: ${startOfDay.toString()}',
    );

    // Filter logs for this specific habit first
    final habitLogs = logs.where((log) => log.habitId == habitId).toList();
    print('DEBUG: Found ${habitLogs.length} logs for habitId: $habitId');

    for (final log in habitLogs) {
      final logDate = DateTime(
        log.completionDate.year,
        log.completionDate.month,
        log.completionDate.day,
      );
      final targetDate = DateTime(date.year, date.month, date.day);

      print(
        'DEBUG: Comparing log date: $logDate with target date: $targetDate',
      );

      if (logDate.isAtSameMomentAs(targetDate)) {
        print(
          'DEBUG: Found matching log for habitId: $habitId on date: $targetDate',
        );
        return log;
      }
    }
    print(
      'DEBUG: No matching log found for habitId: $habitId on date: $startOfDay',
    );
    return null;
  }

  Future<bool> isHabitCompletedOnDate(int habitId, DateTime date) async {
    print(
      'DEBUG: Checking completion for habitId: $habitId on date: ${date.toString()}',
    );
    final log = await getLogByHabitAndDate(habitId, date);
    final isCompleted = log != null;
    print('DEBUG: Habit $habitId completion result: $isCompleted');
    return isCompleted;
  }

  Future<int> logHabitCompletion(int habitId, DateTime date) async {
    await _databaseService.initialize();

    // Check if already logged for this date
    final existing = await getLogByHabitAndDate(habitId, date);
    if (existing != null) {
      return 0; // Already logged
    }

    final log = HabitLog(habitId: habitId, completionDate: date);

    final box = _databaseService.habitLogsBox;
    final index = await box.add(log);
    return index;
  }

  Future<bool> removeHabitLog(int habitId, DateTime date) async {
    await _databaseService.initialize();
    final box = _databaseService.habitLogsBox;

    // Find the log to remove
    int? keyToRemove;
    for (int i = 0; i < box.length; i++) {
      final log = box.getAt(i);
      if (log != null && log.habitId == habitId) {
        final logDate = DateTime(
          log.completionDate.year,
          log.completionDate.month,
          log.completionDate.day,
        );
        final targetDate = DateTime(date.year, date.month, date.day);

        if (logDate.isAtSameMomentAs(targetDate)) {
          keyToRemove = i;
          break;
        }
      }
    }

    if (keyToRemove != null) {
      await box.deleteAt(keyToRemove);
      return true;
    }
    return false;
  }

  Future<int> calculateStreak(int habitId) async {
    await _databaseService.initialize();
    final logs = await getLogsByHabitId(habitId);

    if (logs.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();
    DateTime checkDate = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );

    // Check if completed today
    bool completedToday = logs.any(
      (log) => log.dateOnly.isAtSameMomentAs(checkDate),
    );

    if (!completedToday) {
      // Check if completed yesterday
      checkDate = checkDate.subtract(const Duration(days: 1));
      bool completedYesterday = logs.any(
        (log) => log.dateOnly.isAtSameMomentAs(checkDate),
      );

      if (!completedYesterday) {
        return 0; // Streak broken
      }
    }

    // Count consecutive days
    for (int i = 0; i < logs.length; i++) {
      final logDate = logs[i].dateOnly;

      if (logDate.isAtSameMomentAs(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (logDate.isBefore(checkDate)) {
        // Gap found, streak ends
        break;
      }
    }

    return streak;
  }

  Future<Map<String, int>> getCompletionStatsByCategory() async {
    await _databaseService.initialize();
    final logs = _databaseService.habitLogsBox.values.toList();
    final habitsBox = _databaseService.habitsBox;
    final categoriesBox = _databaseService.categoriesBox;

    Map<String, int> stats = {};

    print('DEBUG getCompletionStatsByCategory: Processing ${logs.length} logs');

    for (final log in logs) {
      // Find the habit for this log using habitId as index
      Habit? habit;
      if (log.habitId >= 0 && log.habitId < habitsBox.length) {
        habit = habitsBox.getAt(log.habitId);
      }

      if (habit != null) {
        // Get category using categoryId as index
        Category? category;
        if (habit.categoryId >= 0 && habit.categoryId < categoriesBox.length) {
          category = categoriesBox.getAt(habit.categoryId);
        }

        if (category != null) {
          final categoryName = category.name;
          stats[categoryName] = (stats[categoryName] ?? 0) + 1;
          print(
            'DEBUG getCompletionStatsByCategory: Log for habit "${habit.title}" -> Category "${categoryName}"',
          );
        } else {
          // Fallback for habits without valid category
          stats['Tanpa Kategori'] = (stats['Tanpa Kategori'] ?? 0) + 1;
          print(
            'DEBUG getCompletionStatsByCategory: Log for habit "${habit.title}" -> No valid category (categoryId: ${habit.categoryId})',
          );
        }
      } else {
        print(
          'DEBUG getCompletionStatsByCategory: No habit found for log with habitId: ${log.habitId}',
        );
      }
    }

    print('DEBUG getCompletionStatsByCategory: Final stats: $stats');
    return stats;
  }

  Future<List<HabitLog>> getLogsInDateRange(
    DateTime start,
    DateTime end,
  ) async {
    await _databaseService.initialize();
    final logs = _databaseService.habitLogsBox.values.toList();

    return logs
        .where(
          (log) =>
              log.completionDate.isAfter(start) &&
              log.completionDate.isBefore(end),
        )
        .toList();
  }
}
