import '../../core/database/database_service.dart';
import '../models/habit.dart';
import '../models/category.dart';

class HabitRepository {
  final DatabaseService _databaseService = DatabaseService.instance;

  Future<List<Habit>> getAllHabits({bool includeArchived = false}) async {
    await _databaseService.initialize();
    final habits = _databaseService.habitsBox.values.toList();
    
    if (includeArchived) {
      return habits;
    } else {
      return habits.where((habit) => !habit.isArchived).toList();
    }
  }

  Future<List<HabitWithCategory>> getHabitsWithCategory({bool includeArchived = false}) async {
    await _databaseService.initialize();
    final habitsBox = _databaseService.habitsBox;
    final categoriesBox = _databaseService.categoriesBox;
    
    List<HabitWithCategory> result = [];
    
    print('DEBUG getHabitsWithCategory: Processing ${habitsBox.length} habits');
    
    for (int i = 0; i < habitsBox.length; i++) {
      final habit = habitsBox.getAt(i);
      if (habit != null && (includeArchived || !habit.isArchived)) {
        // Use index-based access consistently
        Category? category;
        if (habit.categoryId >= 0 && habit.categoryId < categoriesBox.length) {
          category = categoriesBox.getAt(habit.categoryId);
          print('DEBUG getHabitsWithCategory: Habit "${habit.title}" -> Category "${category?.name}" (index ${habit.categoryId})');
        } else {
          print('DEBUG getHabitsWithCategory: Habit "${habit.title}" -> Invalid category index ${habit.categoryId}');
        }
        
        result.add(HabitWithCategory(
          habit: habit, 
          category: category,
          key: i, // Store the actual key
        ));
      }
    }
    
    return result;
  }

  Future<Habit?> getHabitById(int key) async {
    await _databaseService.initialize();
    return _databaseService.habitsBox.get(key);
  }

  Future<int> createHabit(Habit habit) async {
    await _databaseService.initialize();
    print('DEBUG createHabit: Creating habit "${habit.title}" with timer: ${habit.timerDurationMinutes}');
    final box = _databaseService.habitsBox;
    final key = await box.add(habit);
    print('DEBUG createHabit: Habit created with key $key');
    
    // Verify the habit was saved correctly using the key
    final savedHabit = box.get(key);
    if (savedHabit != null) {
      print('DEBUG createHabit: Verified saved habit timer: ${savedHabit.timerDurationMinutes}');
      print('DEBUG createHabit: Verified saved habit hasTimer: ${savedHabit.hasTimer}');
    } else {
      print('DEBUG createHabit: Warning - Could not verify saved habit with key $key');
    }
    
    return key;
  }

  Future<bool> updateHabit(Habit habit, int key) async {
    await _databaseService.initialize();
    final box = _databaseService.habitsBox;
    if (box.containsKey(key)) {
      await box.put(key, habit);
      return true;
    }
    return false;
  }

  Future<bool> deleteHabit(int key) async {
    await _databaseService.initialize();
    final box = _databaseService.habitsBox;
    
    // Try to delete by key first
    if (box.containsKey(key)) {
      await box.delete(key);
      return true;
    }
    
    // If not found by key, try by index
    if (key < box.length && box.getAt(key) != null) {
      await box.deleteAt(key);
      return true;
    }
    
    return false;
  }

  Future<bool> archiveHabit(int key, bool isArchived) async {
    await _databaseService.initialize();
    final box = _databaseService.habitsBox;
    
    // Try to get by key first
    Habit? habit = box.get(key);
    
    // If not found by key, try by index
    if (habit == null && key < box.length) {
      habit = box.getAt(key);
      if (habit != null) {
        // Update using the index as key
        habit.isArchived = isArchived;
        await box.putAt(key, habit);
        return true;
      }
    } else if (habit != null) {
      // Found by key, update normally
      habit.isArchived = isArchived;
      await box.put(key, habit);
      return true;
    }
    
    return false;
  }

  Future<List<HabitWithCategory>> getArchivedHabits() async {
    await _databaseService.initialize();
    final habitsBox = _databaseService.habitsBox;
    final categoriesBox = _databaseService.categoriesBox;
    
    List<HabitWithCategory> result = [];
    
    for (int i = 0; i < habitsBox.length; i++) {
      final habit = habitsBox.getAt(i);
      if (habit != null && habit.isArchived) { // Only archived habits
        // Use index-based access consistently
        Category? category;
        if (habit.categoryId >= 0 && habit.categoryId < categoriesBox.length) {
          category = categoriesBox.getAt(habit.categoryId);
        }
        
        result.add(HabitWithCategory(
          habit: habit, 
          category: category,
          key: i,
        ));
      }
    }
    
    return result;
  }

  Future<int?> getHabitKey(Habit habit) async {
    await _databaseService.initialize();
    final box = _databaseService.habitsBox;
    
    for (int i = 0; i < box.length; i++) {
      final h = box.getAt(i);
      if (h?.title == habit.title && h?.createdDate == habit.createdDate) {
        return i;
      }
    }
    return null;
  }
}

class HabitWithCategory {
  final Habit habit;
  final Category? category;
  final int? key;

  HabitWithCategory({
    required this.habit,
    this.category,
    this.key,
  });
}