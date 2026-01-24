import 'package:hive/hive.dart';

part 'habit_frequency.g.dart';

@HiveType(typeId: 4)
enum HabitFrequency {
  @HiveField(0)
  daily,    // Setiap Hari
  
  @HiveField(1)
  weekly,   // Setiap Minggu
  
  @HiveField(2)
  once,     // Sekali
}

extension HabitFrequencyExtension on HabitFrequency {
  String get displayName {
    switch (this) {
      case HabitFrequency.daily:
        return 'Setiap Hari';
      case HabitFrequency.weekly:
        return 'Setiap Minggu';
      case HabitFrequency.once:
        return 'Sekali';
    }
  }

  String get description {
    switch (this) {
      case HabitFrequency.daily:
        return 'Kebiasaan akan reset setiap hari';
      case HabitFrequency.weekly:
        return 'Kebiasaan akan reset setiap minggu';
      case HabitFrequency.once:
        return 'Kebiasaan hanya dilakukan sekali';
    }
  }
}