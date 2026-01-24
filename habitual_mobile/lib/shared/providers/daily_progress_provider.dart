import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/habit_repository.dart';
import '../repositories/habit_log_repository.dart';
import 'habit_provider.dart';

class DailyProgressData {
  final int totalHabits;
  final int completedHabits;
  final double progress;
  final Map<int, bool> completionStatus; // habitKey -> isCompleted

  DailyProgressData({
    required this.totalHabits,
    required this.completedHabits,
    required this.progress,
    required this.completionStatus,
  });

  DailyProgressData.empty()
      : totalHabits = 0,
        completedHabits = 0,
        progress = 0.0,
        completionStatus = {};
}

final dailyProgressProvider = StateNotifierProvider<DailyProgressNotifier, AsyncValue<DailyProgressData>>((ref) {
  final habitRepository = ref.read(habitRepositoryProvider);
  final logRepository = ref.read(habitLogRepositoryProvider);
  return DailyProgressNotifier(habitRepository, logRepository, ref);
});

class DailyProgressNotifier extends StateNotifier<AsyncValue<DailyProgressData>> {
  final HabitRepository _habitRepository;
  final HabitLogRepository _logRepository;
  final Ref _ref;

  DailyProgressNotifier(this._habitRepository, this._logRepository, this._ref) 
      : super(const AsyncValue.loading()) {
    loadDailyProgress();
    
    // Listen to habit changes to refresh progress
    _ref.listen(habitsProvider, (previous, next) {
      loadDailyProgress();
    });
  }

  Future<void> loadDailyProgress() async {
    try {
      state = const AsyncValue.loading();
      
      // Get all active habits
      final habitsWithCategory = await _habitRepository.getHabitsWithCategory();
      final activeHabits = habitsWithCategory.where((h) => !h.habit.isArchived).toList();
      
      final today = DateTime.now();
      final completionStatus = <int, bool>{};
      int completedCount = 0;
      
      // Check completion status for each habit
      for (final habitWithCategory in activeHabits) {
        final habitKey = habitWithCategory.key;
        if (habitKey != null) {
          final isCompleted = await _logRepository.isHabitCompletedOnDate(habitKey, today);
          completionStatus[habitKey] = isCompleted;
          if (isCompleted) completedCount++;
        }
      }
      
      final totalHabits = activeHabits.length;
      final progress = totalHabits > 0 ? completedCount / totalHabits : 0.0;
      
      state = AsyncValue.data(DailyProgressData(
        totalHabits: totalHabits,
        completedHabits: completedCount,
        progress: progress,
        completionStatus: completionStatus,
      ));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggleHabitCompletion(int habitKey) async {
    try {
      final today = DateTime.now();
      final isCompleted = await _logRepository.isHabitCompletedOnDate(habitKey, today);
      
      if (isCompleted) {
        await _logRepository.removeHabitLog(habitKey, today);
      } else {
        await _logRepository.logHabitCompletion(habitKey, today);
      }
      
      // Refresh progress after toggle
      await loadDailyProgress();
    } catch (error) {
      // Handle error silently or show notification
      print('Error toggling habit completion: $error');
    }
  }

  bool isHabitCompleted(int habitKey) {
    return state.maybeWhen(
      data: (data) => data.completionStatus[habitKey] ?? false,
      orElse: () => false,
    );
  }
}