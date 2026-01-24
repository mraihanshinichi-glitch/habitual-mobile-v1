class HabitTemplate {
  final String title;
  final String description;
  final String category;
  final String icon;
  final int color;
  final List<String> tags;
  final String difficulty; // 'easy', 'medium', 'hard'
  final String frequency; // 'daily', 'weekly', 'monthly'

  const HabitTemplate({
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
    this.tags = const [],
    this.difficulty = 'medium',
    this.frequency = 'daily',
  });

  factory HabitTemplate.fromJson(Map<String, dynamic> json) {
    return HabitTemplate(
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      icon: json['icon'] as String,
      color: json['color'] as int,
      tags: List<String>.from(json['tags'] ?? []),
      difficulty: json['difficulty'] as String? ?? 'medium',
      frequency: json['frequency'] as String? ?? 'daily',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'icon': icon,
      'color': color,
      'tags': tags,
      'difficulty': difficulty,
      'frequency': frequency,
    };
  }
}