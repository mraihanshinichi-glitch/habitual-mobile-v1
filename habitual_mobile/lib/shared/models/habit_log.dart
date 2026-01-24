import 'package:hive/hive.dart';

part 'habit_log.g.dart';

@HiveType(typeId: 2)
class HabitLog extends HiveObject {
  @HiveField(0)
  int habitId;

  @HiveField(1)
  DateTime completionDate;

  HabitLog({
    required this.habitId,
    required this.completionDate,
  });

  HabitLog.empty()
      : habitId = 0,
        completionDate = DateTime.now();

  // Helper method to get date without time
  DateTime get dateOnly {
    return DateTime(
      completionDate.year,
      completionDate.month,
      completionDate.day,
    );
  }
}