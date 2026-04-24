import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';
import '../../core/constants/app_icons.dart';

class CategorySelector extends ConsumerWidget {
  final Category? selectedCategory;
  final ValueChanged<Category?> onCategorySelected;
  final String? hintText;

  const CategorySelector({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
    this.hintText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryProvider);

    return categoriesAsync.when(
      data: (categories) => _buildSelector(context, categories),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('Error: $error'),
    );
  }

  Widget _buildSelector(BuildContext context, List<Category> categories) {
    print(
      'DEBUG CategorySelector: selectedCategory = ${selectedCategory?.name}',
    );
    print(
      'DEBUG CategorySelector: available categories = ${categories.map((c) => c.name).toList()}',
    );

    // Find the actual category object from the list that matches selectedCategory
    Category? actualSelectedCategory;
    if (selectedCategory != null) {
      // Use the new equals method to find matching category
      try {
        actualSelectedCategory = categories.firstWhere(
          (cat) => cat == selectedCategory,
        );
        print(
          'DEBUG CategorySelector: Found exact match: ${actualSelectedCategory.name}',
        );
      } catch (e) {
        // Fallback to name matching
        try {
          actualSelectedCategory = categories.firstWhere(
            (cat) => cat.name == selectedCategory!.name,
          );
          print(
            'DEBUG CategorySelector: Found name match: ${actualSelectedCategory.name}',
          );
        } catch (e2) {
          actualSelectedCategory = categories.isNotEmpty
              ? categories.first
              : null;
          print(
            'DEBUG CategorySelector: Using fallback: ${actualSelectedCategory?.name}',
          );
        }
      }
    }

    return DropdownButtonFormField<Category>(
      initialValue: actualSelectedCategory,
      decoration: InputDecoration(
        labelText: 'Kategori',
        hintText: hintText ?? 'Pilih kategori',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: actualSelectedCategory != null
            ? Icon(
                AppIcons.getIcon(actualSelectedCategory.icon),
                color: Color(actualSelectedCategory.color),
              )
            : const Icon(Icons.category),
      ),
      items: categories.map((category) {
        return DropdownMenuItem<Category>(
          value: category,
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Color(category.color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  AppIcons.getIcon(category.icon),
                  color: Color(category.color),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(category.name),
            ],
          ),
        );
      }).toList(),
      onChanged: onCategorySelected,
      validator: (value) {
        if (value == null) {
          return 'Pilih kategori';
        }
        return null;
      },
    );
  }
}
