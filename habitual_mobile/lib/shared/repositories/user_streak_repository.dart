import '../../core/database/database_service.dart';
import '../models/user_streak.dart';

class UserStreakRepository {
  final _db = DatabaseService.instance;

  Future<UserStreak> getUserStreak() async {
    await _db.initialize();
    
    final box = _db.userStreakBox;
    
    if (box.isEmpty) {
      // Create default streak
      final defaultStreak = UserStreak();
      await box.add(defaultStreak);
      return defaultStreak;
    }
    
    return box.getAt(0) ?? UserStreak();
  }

  Future<void> saveUserStreak(UserStreak streak) async {
    await _db.initialize();
    
    final box = _db.userStreakBox;
    
    if (box.isEmpty) {
      await box.add(streak);
    } else {
      await box.putAt(0, streak);
    }
  }

  Future<void> deleteUserStreak() async {
    await _db.initialize();
    await _db.userStreakBox.clear();
  }
}
