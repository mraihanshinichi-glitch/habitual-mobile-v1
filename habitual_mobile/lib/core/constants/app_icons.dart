import 'package:flutter/material.dart';

class AppIcons {
  static const Map<String, IconData> categoryIcons = {
    'favorite': Icons.favorite,
    'school': Icons.school,
    'work': Icons.work,
    'fitness_center': Icons.fitness_center,
    'palette': Icons.palette,
    'restaurant': Icons.restaurant,
    'local_drink': Icons.local_drink,
    'book': Icons.book,
    'music_note': Icons.music_note,
    'camera_alt': Icons.camera_alt,
    'directions_run': Icons.directions_run,
    'spa': Icons.spa,
    'psychology': Icons.psychology,
    'savings': Icons.savings,
    'home': Icons.home,
    'pets': Icons.pets,
    'eco': Icons.eco,
    'lightbulb': Icons.lightbulb,
    'self_improvement': Icons.self_improvement,
    'category': Icons.category,
  };

  static IconData getIcon(String iconName) {
    return categoryIcons[iconName] ?? Icons.category;
  }

  static List<String> get availableIcons => categoryIcons.keys.toList();
}