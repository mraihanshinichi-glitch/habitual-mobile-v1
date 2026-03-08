import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_streak.dart';
import '../repositories/user_streak_repository.dart';
import '../services/notification_service.dart';

final userStreakRepositoryProvider = Provider<UserStreakRepository>((ref) {
  return UserStreakRepository();
});

final userStreakProvider = StateNotifierProvider<UserStreakNotifier, UserStreak>((ref) {
  final repository = ref.watch(userStreakRepositoryProvider);
  return UserStreakNotifier(repository);
});

class UserStreakNotifier extends StateNotifier<UserStreak> {
  final UserStreakRepository _repository;
  final NotificationService _notificationService = NotificationService();

  UserStreakNotifier(this._repository) : super(UserStreak()) {
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final streak = await _repository.getUserStreak();
    state = streak;
  }

  Future<void> reloadStreak() async {
    await _loadStreak();
  }

  Future<void> checkAndUpdateStreak(bool allHabitsCompleted) async {
    print('DEBUG checkAndUpdateStreak: Called with allHabitsCompleted=$allHabitsCompleted');
    print('DEBUG checkAndUpdateStreak: Current streak=${state.currentStreak}');
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCheck = state.lastCheckDate != null
        ? DateTime(
            state.lastCheckDate!.year,
            state.lastCheckDate!.month,
            state.lastCheckDate!.day,
          )
        : null;

    print('DEBUG checkAndUpdateStreak: Today=$today, LastCheck=$lastCheck');

    // Jangan update jika sudah dicek hari ini
    if (lastCheck != null && lastCheck.isAtSameMomentAs(today)) {
      print('DEBUG checkAndUpdateStreak: Already checked today, skipping');
      return;
    }

    final lastCompletion = DateTime(
      state.lastCompletionDate.year,
      state.lastCompletionDate.month,
      state.lastCompletionDate.day,
    );

    final daysDifference = today.difference(lastCompletion).inDays;
    print('DEBUG checkAndUpdateStreak: LastCompletion=$lastCompletion, DaysDifference=$daysDifference');

    // LOGIKA BARU: Streak bertambah saat ada habit yang diselesaikan (tidak perlu semua)
    // allHabitsCompleted di sini berarti "ada minimal 1 habit yang diselesaikan hari ini"
    if (allHabitsCompleted) {
      print('DEBUG checkAndUpdateStreak: At least one habit completed today!');
      
      // Jika ini pertama kali atau streak saat ini 0, mulai dari 1
      if (state.currentStreak == 0) {
        print('DEBUG checkAndUpdateStreak: Starting new streak from 1');
        
        final updatedStreak = UserStreak(
          currentStreak: 1,
          longestStreak: state.longestStreak > 1 ? state.longestStreak : 1,
          lastCompletionDate: today,
          lastCheckDate: today,
        );
        
        await _repository.saveUserStreak(updatedStreak);
        state = updatedStreak;
        print('DEBUG checkAndUpdateStreak: New streak started at 1');
        
        await _checkStreakMilestone(1);
      } else if (daysDifference == 0) {
        // Hari yang sama, update lastCheckDate saja
        print('DEBUG checkAndUpdateStreak: Same day, updating lastCheckDate');
        
        final updatedStreak = UserStreak(
          currentStreak: state.currentStreak,
          longestStreak: state.longestStreak,
          lastCompletionDate: state.lastCompletionDate,
          lastCheckDate: today,
        );
        
        await _repository.saveUserStreak(updatedStreak);
        state = updatedStreak;
      } else if (daysDifference == 1) {
        // Hari berturut-turut
        final newStreak = state.currentStreak + 1;
        final newLongest = newStreak > state.longestStreak ? newStreak : state.longestStreak;
        
        print('DEBUG checkAndUpdateStreak: Consecutive day! NewStreak=$newStreak, NewLongest=$newLongest');
        
        final updatedStreak = UserStreak(
          currentStreak: newStreak,
          longestStreak: newLongest,
          lastCompletionDate: today,
          lastCheckDate: today,
        );
        
        await _repository.saveUserStreak(updatedStreak);
        state = updatedStreak;
        print('DEBUG checkAndUpdateStreak: Streak updated and saved');
        
        // Send notification for streak milestones
        await _checkStreakMilestone(newStreak);
      } else {
        // Terputus, mulai dari 1
        print('DEBUG checkAndUpdateStreak: Streak broken (gap=$daysDifference days), starting from 1');
        
        final previousStreak = state.currentStreak;
        
        final updatedStreak = UserStreak(
          currentStreak: 1,
          longestStreak: state.longestStreak,
          lastCompletionDate: today,
          lastCheckDate: today,
        );
        
        await _repository.saveUserStreak(updatedStreak);
        state = updatedStreak;
        print('DEBUG checkAndUpdateStreak: New streak started at 1');
        
        // Send streak reset notification if previous streak was > 0
        if (previousStreak > 0) {
          await _notificationService.showStreakResetNotification();
        }
        
        await _checkStreakMilestone(1);
      }
    } else {
      print('DEBUG checkAndUpdateStreak: No habits completed today');
      // Tidak ada kebiasaan yang diselesaikan hari ini
      if (daysDifference >= 1 && state.currentStreak > 0) {
        final previousStreak = state.currentStreak;
        print('DEBUG checkAndUpdateStreak: Resetting streak from $previousStreak to 0');
        
        // Reset streak
        final updatedStreak = UserStreak(
          currentStreak: 0,
          longestStreak: state.longestStreak,
          lastCompletionDate: state.lastCompletionDate,
          lastCheckDate: today,
        );
        
        await _repository.saveUserStreak(updatedStreak);
        state = updatedStreak;
        print('DEBUG checkAndUpdateStreak: Streak reset to 0');
        
        // Send streak reset notification
        await _notificationService.showStreakResetNotification();
      } else {
        // Update lastCheckDate saja
        print('DEBUG checkAndUpdateStreak: Updating lastCheckDate only');
        
        final updatedStreak = UserStreak(
          currentStreak: state.currentStreak,
          longestStreak: state.longestStreak,
          lastCompletionDate: state.lastCompletionDate,
          lastCheckDate: today,
        );
        
        await _repository.saveUserStreak(updatedStreak);
        state = updatedStreak;
      }
    }
  }

  Future<void> _checkStreakMilestone(int streak) async {
    // Send notifications for specific milestones
    String? message;
    
    if (streak == 3) {
      message = 'Hebat! Anda telah mencapai streak 3 hari! 🎉';
    } else if (streak == 7) {
      message = 'Luar biasa! Streak 7 hari tercapai! Satu minggu penuh! 🌟';
    } else if (streak == 14) {
      message = 'Fantastis! Streak 14 hari! Dua minggu konsisten! 💪';
    } else if (streak == 30) {
      message = 'Menakjubkan! Streak 30 hari! Satu bulan penuh! 🏆';
    } else if (streak == 50) {
      message = 'Luar biasa! Streak 50 hari! Anda adalah juara! 👑';
    } else if (streak == 100) {
      message = 'LEGENDARIS! Streak 100 hari! Anda adalah master kebiasaan! 🎖️';
    } else if (streak % 10 == 0 && streak > 0) {
      message = 'Keren! Streak $streak hari! Terus pertahankan! 🔥';
    }
    
    if (message != null) {
      await _notificationService.showStreakNotification(
        streak: streak,
        message: message,
      );
    }
  }

  Future<void> resetStreak() async {
    final updatedStreak = UserStreak(
      currentStreak: 0,
      longestStreak: state.longestStreak,
      lastCompletionDate: DateTime.now(),
      lastCheckDate: DateTime.now(),
    );
    
    await _repository.saveUserStreak(updatedStreak);
    state = updatedStreak;
  }
}
