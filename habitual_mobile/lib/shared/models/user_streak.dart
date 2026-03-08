import 'package:hive/hive.dart';

part 'user_streak.g.dart';

@HiveType(typeId: 5)
class UserStreak extends HiveObject {
  @HiveField(0)
  int currentStreak;

  @HiveField(1)
  int longestStreak;

  @HiveField(2)
  DateTime lastCompletionDate;

  @HiveField(3)
  DateTime? lastCheckDate;

  UserStreak({
    this.currentStreak = 0,
    this.longestStreak = 0,
    DateTime? lastCompletionDate,
    this.lastCheckDate,
  }) : lastCompletionDate = lastCompletionDate ?? DateTime.now();
}
