import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 0)
class Category extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int color;

  @HiveField(2)
  String icon;

  @HiveField(3)
  DateTime createdAt;

  Category({
    required this.name,
    required this.color,
    required this.icon,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Category.empty()
      : name = '',
        color = 0xFF2196F3,
        icon = 'category',
        createdAt = DateTime.now();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category &&
        other.name == name &&
        other.color == color &&
        other.icon == icon;
  }

  @override
  int get hashCode => name.hashCode ^ color.hashCode ^ icon.hashCode;

  @override
  String toString() {
    return 'Category(name: $name, color: $color, icon: $icon)';
  }
}