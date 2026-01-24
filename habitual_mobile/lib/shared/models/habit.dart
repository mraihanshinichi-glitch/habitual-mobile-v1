import 'package:hive/hive.dart';
import 'habit_frequency.dart';

part 'habit.g.dart';

@HiveType(typeId: 1)
class Habit extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String? description;

  @HiveField(2)
  int categoryId;

  @HiveField(3)
  bool isArchived;

  @HiveField(4)
  DateTime createdDate;

  @HiveField(5)
  HabitFrequency? frequency;

  @HiveField(6)
  int? timerDurationMinutes; // Timer duration in minutes

  @HiveField(7)
  bool? hasNotification;

  @HiveField(8)
  DateTime? notificationTime;

  Habit({
    required this.title,
    this.description,
    required this.categoryId,
    this.isArchived = false,
    DateTime? createdDate,
    this.frequency,
    this.timerDurationMinutes,
    this.hasNotification,
    this.notificationTime,
  }) : createdDate = createdDate ?? DateTime.now();

  Habit.empty()
      : title = '',
        description = '',
        categoryId = 0,
        isArchived = false,
        createdDate = DateTime.now(),
        frequency = HabitFrequency.daily,
        timerDurationMinutes = null,
        hasNotification = false,
        notificationTime = null;

  // Getters with default values for backward compatibility
  HabitFrequency get effectiveFrequency => frequency ?? HabitFrequency.daily;
  bool get effectiveHasNotification => hasNotification ?? false;
  String get frequencyDisplayName => effectiveFrequency.displayName;

  bool get hasTimer => timerDurationMinutes != null && timerDurationMinutes! > 0;
}