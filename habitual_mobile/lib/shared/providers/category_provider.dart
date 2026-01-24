import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../repositories/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.read(categoryRepositoryProvider);
  return await repository.getAllCategories();
});

// Add a separate provider that watches the categoryProvider state
final categoriesListProvider = Provider<AsyncValue<List<Category>>>((ref) {
  return ref.watch(categoryProvider);
});

final categoryProvider = StateNotifierProvider<CategoryNotifier, AsyncValue<List<Category>>>((ref) {
  final repository = ref.read(categoryRepositoryProvider);
  return CategoryNotifier(repository);
});

class CategoryNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final CategoryRepository _repository;

  CategoryNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      state = const AsyncValue.loading();
      final categories = await _repository.getAllCategories();
      state = AsyncValue.data(categories);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<bool> addCategory(Category category) async {
    try {
      // Check if category name already exists
      final exists = await _repository.categoryExists(category.name);
      if (exists) {
        return false;
      }

      await _repository.createCategory(category);
      await loadCategories(); // Refresh the list
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<bool> updateCategory(Category category) async {
    try {
      await _repository.updateCategory(category);
      await loadCategories(); // Refresh the list
      return true;
    } catch (error) {
      return false;
    }
  }

  Future<bool> deleteCategory(int key) async {
    try {
      await _repository.deleteCategory(key);
      await loadCategories(); // Refresh the list
      return true;
    } catch (error) {
      return false;
    }
  }
}