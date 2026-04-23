import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../repositories/habit_repository.dart';
import '../repositories/habit_log_repository.dart';
import '../services/background_service.dart';
import 'user_streak_provider.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository();
});

final habitLogRepositoryProvider = Provider<HabitLogRepository>((ref) {
  return HabitLogRepository();
});

final habitsProvider = StateNotifierProvider<HabitNotifier, AsyncValue<List<HabitWithCategory>>>((ref) {
  final habitRepository = ref.read(habitRepositoryProvider);
  final logRepository = ref.read(habitLogRepositoryProvider);
  return HabitNotifier(habitRepository, logRepository, ref);
});

final archivedHabitsProvider = FutureProvider<List<HabitWithCategory>>((ref) async {
  final repository = ref.read(habitRepositoryProvider);
  return await repository.getArchivedHabits();
});

class HabitNotifier extends StateNotifier<AsyncValue<List<HabitWithCategory>>> {
  final HabitRepository _habitRepository;
  final HabitLogRepository _logRepository;
  final Ref _ref;

  HabitNotifier(this._habitRepository, this._logRepository, this._ref) 
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
      
      // Reschedule all notification to ensure sync
      await BackgroundService().rescheduleAllNotifications();
      
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
      
      // Reschedule all notification to ensure sync
      await BackgroundService().rescheduleAllNotifications();
      
      await loadHabits(); // Refresh the list
      return true;
    } catch (error) {
      print('DEBUG updateHabit: Error updating habit: $error');
      return false;
    }
  }

  Future<bool> deleteHabit(int key) async {
    try {
      // Notification rescheduling will be handled after deletion
      
      await _habitRepository.deleteHabit(key);
      await BackgroundService().rescheduleAllNotifications();
      await loadHabits(); // Refresh the list
      return true;
    } catch (error) {
      return false;
    }
  }


  Future<bool> archiveHabit(int key, bool isArchived) async {
    try {
      await _habitRepository.archiveHabit(key, isArchived);
      await BackgroundService().rescheduleAllNotifications();
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
      
      // Check if all habits are completed today and update user streak
      await _checkAndUpdateUserStreak();
      
      // Notify listeners that state has changed
      state = state;
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<void> _checkAndUpdateUserStreak() async {
    try {
      print('DEBUG _checkAndUpdateUserStreak: Starting check...');
      
      // Get all active (non-archived) habits
      final allHabits = await _habitRepository.getHabitsWithCategory();
      final activeHabits = allHabits.where((hwc) => !hwc.habit.isArchived).toList();
      
      print('DEBUG _checkAndUpdateUserStreak: Total habits=${allHabits.length}, Active habits=${activeHabits.length}');
      
      if (activeHabits.isEmpty) {
        print('DEBUG _checkAndUpdateUserStreak: No active habits, skipping');
        return; // No habits to check
      }
      
      // Check if at least one habit is completed today
      final today = DateTime.now();
      bool anyCompleted = false;
      int completedCount = 0;
      
      for (final hwc in activeHabits) {
        final habitKey = hwc.key;
        if (habitKey != null) {
          final isCompleted = await _logRepository.isHabitCompletedOnDate(habitKey, today);
          print('DEBUG _checkAndUpdateUserStreak: Habit "${hwc.habit.title}" (key=$habitKey) completed=$isCompleted');
          
          if (isCompleted) {
            completedCount++;
            anyCompleted = true;
          }
        }
      }
      
      print('DEBUG _checkAndUpdateUserStreak: Completed=$completedCount/${activeHabits.length}, AnyCompleted=$anyCompleted');
      
      // Update user streak - pass true if any habit completed
      await _ref.read(userStreakProvider.notifier).checkAndUpdateStreak(anyCompleted);
      print('DEBUG _checkAndUpdateUserStreak: User streak update completed');
    } catch (e, stackTrace) {
      print('DEBUG _checkAndUpdateUserStreak: Error: $e');
      print('DEBUG _checkAndUpdateUserStreak: StackTrace: $stackTrace');
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