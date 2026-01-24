import '../../core/database/database_service.dart';
import '../models/category.dart';

class CategoryRepository {
  final DatabaseService _databaseService = DatabaseService.instance;

  Future<List<Category>> getAllCategories() async {
    await _databaseService.initialize();
    return _databaseService.categoriesBox.values.toList();
  }

  Future<Category?> getCategoryById(int id) async {
    await _databaseService.initialize();
    final box = _databaseService.categoriesBox;
    
    // Use index-based access consistently
    if (id >= 0 && id < box.length) {
      return box.getAt(id);
    }
    
    return null;
  }

  Future<int> createCategory(Category category) async {
    await _databaseService.initialize();
    final box = _databaseService.categoriesBox;
    final index = await box.add(category);
    return index;
  }

  Future<bool> updateCategory(Category category) async {
    await _databaseService.initialize();
    final box = _databaseService.categoriesBox;
    
    // Find the key for this category
    int? key;
    for (int i = 0; i < box.length; i++) {
      if (box.getAt(i) == category) {
        key = i;
        break;
      }
    }
    
    if (key != null) {
      await box.putAt(key, category);
      return true;
    }
    return false;
  }

  Future<bool> deleteCategory(int index) async {
    await _databaseService.initialize();
    final box = _databaseService.categoriesBox;
    if (index >= 0 && index < box.length) {
      await box.deleteAt(index);
      return true;
    }
    return false;
  }

  Future<bool> categoryExists(String name) async {
    await _databaseService.initialize();
    final categories = await getAllCategories();
    return categories.any((category) => category.name == name);
  }

  Future<int?> getCategoryKey(Category category) async {
    await _databaseService.initialize();
    final box = _databaseService.categoriesBox;
    
    print('DEBUG getCategoryKey: Looking for category: ${category.name}');
    print('DEBUG getCategoryKey: Box length: ${box.length}');
    
    // Print all categories in box for debugging
    for (int i = 0; i < box.length; i++) {
      final cat = box.getAt(i);
      print('DEBUG getCategoryKey: Index $i: ${cat?.name}');
    }
    
    // First try to find by exact object match
    for (int i = 0; i < box.length; i++) {
      final cat = box.getAt(i);
      if (cat != null && 
          cat.name == category.name && 
          cat.color == category.color && 
          cat.icon == category.icon) {
        print('DEBUG getCategoryKey: Found exact match at index $i');
        return i;
      }
    }
    
    // Fallback: find by name only
    for (int i = 0; i < box.length; i++) {
      final cat = box.getAt(i);
      if (cat?.name == category.name) {
        print('DEBUG getCategoryKey: Found name match at index $i');
        return i;
      }
    }
    
    print('DEBUG getCategoryKey: No match found for ${category.name}');
    return null;
  }
}