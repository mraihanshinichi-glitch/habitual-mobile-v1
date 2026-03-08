// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_streak.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserStreakAdapter extends TypeAdapter<UserStreak> {
  @override
  final int typeId = 5;

  @override
  UserStreak read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserStreak(
      currentStreak: fields[0] as int,
      longestStreak: fields[1] as int,
      lastCompletionDate: fields[2] as DateTime?,
      lastCheckDate: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserStreak obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.currentStreak)
      ..writeByte(1)
      ..write(obj.longestStreak)
      ..writeByte(2)
      ..write(obj.lastCompletionDate)
      ..writeByte(3)
      ..write(obj.lastCheckDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserStreakAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
