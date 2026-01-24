import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../repositories/habit_repository.dart';
import '../repositories/habit_log_repository.dart';
import '../services/notification_service.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository();
});

final habitLogRepositoryProvider = Provider<HabitLogRepository>((ref) {
  return HabitLogRepository();
});

final habitsProvider = StateNotifierProvider<HabitNotifier, AsyncValue<List<HabitWithCategory>>>((ref) {
  final habitRepository = ref.read(habitRepositoryProvider);
  final logRepository = ref.read(habitLogRepositoryProvider);
  return HabitNotifier(habitRepository, logRepository);
});

final archivedHabitsProvider = FutureProvider<List<HabitWithCategory>>((ref) async {
  final repository = ref.read(habitRepositoryProvider);
  return await repository.getArchivedHabits();
});

class HabitNotifier extends StateNotifier<AsyncValue<List<HabitWithCategory>>> {
  final HabitRepository _habitRepository;
  final HabitLogRepository _logRepository;
  final NotificationService _notificationService = NotificationService();

  HabitNotifier(this._habitRepository, this._logRepository) 
      : super(const AsyncValue.loading()) {
    loadHabits();
  }

  Future<void> loadHabits() async {
    try {
      state = const AsyncValue.loading();
      final habits = await _habitRepository.getHabitsWithCategory();
      state = AsyncValue.data(habits);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<bool> addHabit(Habit habit) async {
    try {
      print('DEBUG addHabit: Creating new habit: ${habit.title}');
      print('DEBUG addHabit: Timer duration: ${habit.timerDurationMinutes}');
      print('DEBUG addHabit: Has timer: ${habit.hasTimer}');
      print('DEBUG addHabit: Has notification: ${habit.effectiveHasNotification}');
      print('DEBUG addHabit: Notification time: ${habit.notificationTime}');
      
      final habitKey = await _habitRepository.createHabit(habit);
      print('DEBUG addHabit: Created habit with key: $habitKey');
      
      // Schedule notification if enabled
      if (habit.effectiveHasNotification && habit.notificationTime != null) {
        await _scheduleHabitNotification(habitKey, habit);
      }
      
      // DO NOT create any habit logs for new habits
      // Let user manually complete them
      
      await loadHabits(); // Refresh the list
      return true;
    } catch (error) {
      print('DEBUG addHabit: Error creating habit: $error');
      return false;
    }
  }

  Future<bool> updateHabit(Habit habit, int key) async {
    try {
      print('DEBUG updateHabit: Updating habit: ${habit.title}');
      print('DEBUG updateHabit: Has notification: ${habit.effectiveHasNotification}');
      print('DEBUG updateHabit: Notification time: ${habit.notificationTime}');
      
      await _habitRepository.updateHabit(habit, key);
      
      // Cancel existing notification
      await _notificationService.cancelHabitNotification(key);
      
      // Schedule new notification if enabled
      if (habit.effectiveHasNotification && habit.notificationTime != null) {
        await _scheduleHabitNotification(key, habit);
      }
      
      await loadHabits(); // Refresh the list
      return true;
    } catch (error) {
      print('DEBUG updateHabit: Error updating habit: $error');
      return false;
    }
  }

  Future<bool> deleteHabit(int key) async {
    try {
      // Cancel notification before deleting habit
      await _notificationService.cancelHabitNotification(key);
      
      await _habitRepository.deleteHabit(key);
      await loadHabits(); // Refresh the list
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<void> _scheduleHabitNotification(int habitKey, Habit habit) async {
    try {
      if (habit.notificationTime != null) {
        await _notificationService.scheduleDailyHabitReminder(
          habitId: habitKey,
          habitTitle: habit.title,
          hour: habit.notificationTime!.hour,
          minute: habit.notificationTime!.minute,
        );
        print('DEBUG _scheduleHabitNotification: Scheduled notification for "${habit.title}" at ${habit.notificationTime!.hour}:${habit.notificationTime!.minute}');
      }
    } catch (e) {
      print('DEBUG _scheduleHabitNotification: Error scheduling notification: $e');
    }
  }

  Future<bool> archiveHabit(int key, bool isArchived) async {
    try {
      await _habitRepository.archiveHabit(key, isArchived);
      await loadHabits(); // Refresh the list
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<bool> toggleHabitCompletion(int habitKey, DateTime date) async {
    try {
      final isCompleted = await _logRepository.isHabitCompletedOnDate(habitKey, date);
      
      if (isCompleted) {
        await _logRepository.removeHabitLog(habitKey, date);
      } else {
        await _logRepository.logHabitCompletion(habitKey, date);
      }
      
      // Notify listeners that state has changed
      state = state;
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<int> getHabitStreak(int habitKey) async {
    return await _logRepository.calculateStreak(habitKey);
  }

  Future<bool> isHabitCompletedToday(int habitKey) async {
    final today = DateTime.now();
    print('DEBUG isHabitCompletedToday: Checking habitKey $habitKey for today ${today.toString()}');
    final result = await _logRepository.isHabitCompletedOnDate(habitKey, today);
    print('DEBUG isHabitCompletedToday: Result for habitKey $habitKey = $result');
    return result;
  }
}