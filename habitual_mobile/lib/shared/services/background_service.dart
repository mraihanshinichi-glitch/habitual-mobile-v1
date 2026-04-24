import '../repositories/habit_repository.dart';
import '../repositories/habit_log_repository.dart';
import '../repositories/user_streak_repository.dart';
import '../models/user_streak.dart';
import 'notification_service.dart';

class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();
  factory BackgroundService() => _instance;
  BackgroundService._internal();

  final HabitRepository _habitRepository = HabitRepository();
  final HabitLogRepository _logRepository = HabitLogRepository();
  final UserStreakRepository _streakRepository = UserStreakRepository();
  final NotificationService _notificationService = NotificationService();

  /// Check dan update streak saat app dibuka
  Future<void> checkDailyStreak() async {
    try {
      print('DEBUG BackgroundService: Checking daily streak...');

      // Get current streak
      final currentStreak = await _streakRepository.getUserStreak();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final lastCheck = currentStreak.lastCheckDate != null
          ? DateTime(
              currentStreak.lastCheckDate!.year,
              currentStreak.lastCheckDate!.month,
              currentStreak.lastCheckDate!.day,
            )
          : null;

      print('DEBUG BackgroundService: Today=$today, LastCheck=$lastCheck');

      // Jika sudah dicek hari ini, skip
      if (lastCheck != null && lastCheck.isAtSameMomentAs(today)) {
        print('DEBUG BackgroundService: Already checked today');
        return;
      }

      // Get all active habits
      final allHabits = await _habitRepository.getHabitsWithCategory();
      final activeHabits = allHabits
          .where((hwc) => !hwc.habit.isArchived)
          .toList();

      if (activeHabits.isEmpty) {
        print('DEBUG BackgroundService: No active habits');
        return;
      }

      // Check if any habit was completed yesterday
      final yesterday = today.subtract(const Duration(days: 1));
      bool anyCompletedYesterday = false;

      for (final hwc in activeHabits) {
        final habitKey = hwc.key;
        if (habitKey != null) {
          final isCompleted = await _logRepository.isHabitCompletedOnDate(
            habitKey,
            yesterday,
          );
          if (isCompleted) {
            anyCompletedYesterday = true;
            break;
          }
        }
      }

      print(
        'DEBUG BackgroundService: AnyCompletedYesterday=$anyCompletedYesterday',
      );

      // Jika kemarin tidak ada habit yang selesai dan streak > 0, reset streak
      if (!anyCompletedYesterday && currentStreak.currentStreak > 0) {
        print(
          'DEBUG BackgroundService: Resetting streak due to no completion yesterday',
        );

        final updatedStreak = UserStreak(
          currentStreak: 0,
          longestStreak: currentStreak.longestStreak,
          lastCompletionDate: currentStreak.lastCompletionDate,
          lastCheckDate: today,
        );

        await _streakRepository.saveUserStreak(updatedStreak);

        // Send reset notification
        await _notificationService.showStreakResetNotification();
      }
    } catch (e, stackTrace) {
      print('DEBUG BackgroundService: Error checking daily streak: $e');
      print('DEBUG BackgroundService: StackTrace: $stackTrace');
    }
  }

  /// Re-schedule semua notifikasi habit
  Future<void> rescheduleAllNotifications() async {
    try {
      print('DEBUG BackgroundService: Rescheduling all notifications...');

      // Get all active habits with notifications
      final allHabits = await _habitRepository.getHabitsWithCategory();
      final habitsWithNotifications = allHabits
          .where(
            (hwc) =>
                !hwc.habit.isArchived &&
                hwc.habit.effectiveHasNotification &&
                hwc.habit.notificationTime != null,
          )
          .toList();

      print(
        'DEBUG BackgroundService: Found ${habitsWithNotifications.length} habits with notifications',
      );

      // Cancel all existing notifications first
      await _notificationService.cancelAllNotifications();

      // Reschedule each habit notification
      for (final hwc in habitsWithNotifications) {
        final habitKey = hwc.key;
        if (habitKey != null) {
          final habit = hwc.habit;
          await _notificationService.scheduleDailyHabitReminder(
            habitId: habitKey,
            habitTitle: habit.title,
            hour: habit.notificationTime!.hour,
            minute: habit.notificationTime!.minute,
          );
          print(
            'DEBUG BackgroundService: Rescheduled notification for "${habit.title}"',
          );
        }
      }

      print('DEBUG BackgroundService: All notifications rescheduled');
    } catch (e, stackTrace) {
      print('DEBUG BackgroundService: Error rescheduling notifications: $e');
      print('DEBUG BackgroundService: StackTrace: $stackTrace');
    }
  }

  /// Initialize background tasks saat app start
  Future<void> initialize() async {
    print('DEBUG BackgroundService: Initializing...');

    // Check daily streak
    await checkDailyStreak();

    // Reschedule all notifications
    await rescheduleAllNotifications();

    // Show test notification untuk verify notifikasi bekerja
    await _showDailyCheckNotification();

    print('DEBUG BackgroundService: Initialization completed');
  }

  /// Show notification untuk confirm daily check
  Future<void> _showDailyCheckNotification() async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Get current streak
      final currentStreak = await _streakRepository.getUserStreak();

      // Hanya show jika ini hari baru (belum dicek hari ini)
      final lastCheck = currentStreak.lastCheckDate != null
          ? DateTime(
              currentStreak.lastCheckDate!.year,
              currentStreak.lastCheckDate!.month,
              currentStreak.lastCheckDate!.day,
            )
          : null;

      if (lastCheck == null || !lastCheck.isAtSameMomentAs(today)) {
        // Show notification untuk remind user
        await _notificationService.showTestNotification();
        print('DEBUG BackgroundService: Daily check notification shown');
      }
    } catch (e) {
      print(
        'DEBUG BackgroundService: Error showing daily check notification: $e',
      );
    }
  }
}
