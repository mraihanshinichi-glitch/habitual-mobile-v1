import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/habit_log_repository.dart';

final statsRepositoryProvider = Provider<HabitLogRepository>((ref) {
  return HabitLogRepository();
});

final categoryStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.read(statsRepositoryProvider);
  return await repository.getCompletionStatsByCategory();
});

final statsProvider =
    StateNotifierProvider<StatsNotifier, AsyncValue<StatsData>>((ref) {
      final repository = ref.read(statsRepositoryProvider);
      return StatsNotifier(repository);
    });

class StatsData {
  final Map<String, int> categoryStats;
  final int thisWeekCompletions;
  final int thisMonthCompletions;

  StatsData({
    required this.categoryStats,
    required this.thisWeekCompletions,
    required this.thisMonthCompletions,
  });
}

class StatsNotifier extends StateNotifier<AsyncValue<StatsData>> {
  final HabitLogRepository _repository;

  StatsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadStats();
  }

  Future<void> loadStats() async {
    try {
      state = const AsyncValue.loading();

      final categoryStats = await _repository.getCompletionStatsByCategory();

      // Calculate this week completions
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfWeekDate = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day,
      );
      final endOfWeek = startOfWeekDate.add(
        const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
      );

      final thisWeekLogs = await _repository.getLogsInDateRange(
        startOfWeekDate,
        endOfWeek,
      );
      final thisWeekCompletions = thisWeekLogs.length;

      // Calculate this month completions
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final thisMonthLogs = await _repository.getLogsInDateRange(
        startOfMonth,
        endOfMonth,
      );
      final thisMonthCompletions = thisMonthLogs.length;

      final statsData = StatsData(
        categoryStats: categoryStats,
        thisWeekCompletions: thisWeekCompletions,
        thisMonthCompletions: thisMonthCompletions,
      );

      state = AsyncValue.data(statsData);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshStats() async {
    await loadStats();
  }
}
