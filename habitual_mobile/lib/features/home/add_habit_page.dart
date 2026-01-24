import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/habit.dart';
import '../../shared/models/category.dart';
import '../../shared/models/habit_template.dart';
import '../../shared/models/habit_frequency.dart';
import '../../shared/providers/habit_provider.dart';
import '../../shared/providers/category_provider.dart';
import '../../shared/services/template_service.dart';
import '../../shared/widgets/category_selector.dart';
import '../../core/constants/app_icons.dart';

class AddHabitPage extends ConsumerStatefulWidget {
  final Habit? habitToEdit;
  final int? habitKey;
  final HabitTemplate? template;

  const AddHabitPage({
    super.key, 
    this.habitToEdit, 
    this.habitKey,
    this.template,
  });

  @override
  ConsumerState<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends ConsumerState<AddHabitPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  Category? _selectedCategory;
  bool _isLoading = false;
  
  // New fields for enhanced features
  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  int? _timerDurationMinutes;
  bool _hasNotification = false;
  TimeOfDay? _notificationTime;

  @override
  void initState() {
    super.initState();
    if (widget.habitToEdit != null) {
      _titleController.text = widget.habitToEdit!.title;
      _descriptionController.text = widget.habitToEdit!.description ?? '';
      
      // Load existing values with defaults for backward compatibility
      _selectedFrequency = widget.habitToEdit!.effectiveFrequency;
      _timerDurationMinutes = widget.habitToEdit!.timerDurationMinutes;
      _hasNotification = widget.habitToEdit!.effectiveHasNotification;
      if (widget.habitToEdit!.notificationTime != null) {
        final time = widget.habitToEdit!.notificationTime!;
        _notificationTime = TimeOfDay(hour: time.hour, minute: time.minute);
      }
      
      _loadSelectedCategory();
    } else if (widget.template != null) {
      _titleController.text = widget.template!.title;
      _descriptionController.text = widget.template!.description;
      _loadTemplateCategory();
    } else {
      // Load default category for new habits
      _loadDefaultCategory();
    }
  }

  Future<void> _loadSelectedCategory() async {
    if (widget.habitToEdit != null) {
      final categoryRepository = ref.read(categoryRepositoryProvider);
      final category = await categoryRepository.getCategoryById(widget.habitToEdit!.categoryId);
      if (category != null) {
        setState(() {
          _selectedCategory = category;
        });
      }
    }
  }

  Future<void> _loadTemplateCategory([HabitTemplate? template]) async {
    final templateToUse = template ?? widget.template;
    if (templateToUse != null) {
      print('DEBUG: Loading template category: ${templateToUse.category}');
      final categories = await ref.read(categoryRepositoryProvider).getAllCategories();
      print('DEBUG: Available categories: ${categories.map((c) => c.name).toList()}');
      
      // Find category by name, with fallback to first category
      Category? matchedCategory;
      for (final cat in categories) {
        if (cat.name == templateToUse.category) {
          matchedCategory = cat;
          print('DEBUG: Found matching category: ${cat.name}');
          break;
        }
      }
      
      // If no match found, use first category as fallback
      if (matchedCategory == null && categories.isNotEmpty) {
        matchedCategory = categories.first;
        print('DEBUG: Using fallback category: ${matchedCategory.name}');
      }
      
      if (matchedCategory != null && mounted) {
        print('DEBUG: Setting selected category to: ${matchedCategory.name}');
        setState(() {
          _selectedCategory = matchedCategory;
        });
      }
    }
  }

  Future<void> _loadDefaultCategory() async {
    final categories = await ref.read(categoryRepositoryProvider).getAllCategories();
    print('DEBUG: Loading default category from ${categories.length} categories');
    if (categories.isNotEmpty && mounted) {
      print('DEBUG: Setting default category to: ${categories.first.name}');
      setState(() {
        _selectedCategory = categories.first;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.habitToEdit != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Kebiasaan' : 'Tambah Kebiasaan'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Template Button (only show when adding new habit)
            if (widget.habitToEdit == null) ...[
              Card(
                elevation: 1,
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: _showTemplateSelector,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.library_books_outlined,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gunakan Template',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                              Text(
                                'Pilih dari 15+ template kebiasaan yang sudah tersedia',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Title field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Judul Kebiasaan',
                hintText: 'Contoh: Minum air 8 gelas',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Judul kebiasaan tidak boleh kosong';
                }
                if (value.trim().length < 3) {
                  return 'Judul kebiasaan minimal 3 karakter';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 16),

            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Deskripsi (Opsional)',
                hintText: 'Jelaskan detail kebiasaan Anda',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 3,
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 16),

            // Category selector
            CategorySelector(
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                print('DEBUG: Category selected: ${category?.name}');
                setState(() {
                  _selectedCategory = category;
                });
              },
            ),

            const SizedBox(height: 16),

            // Frequency selector
            _buildFrequencySelector(),

            const SizedBox(height: 16),

            // Timer section
            _buildTimerSection(),

            const SizedBox(height: 16),

            // Notification section
            _buildNotificationSection(),

            const SizedBox(height: 32),

            // Save button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveHabit,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        isEditing ? 'Perbarui Kebiasaan' : 'Simpan Kebiasaan',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),

            if (isEditing) ...[
              const SizedBox(height: 16),
              
              // Archive button
              SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _archiveHabit,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Text(
                    widget.habitToEdit!.isArchived 
                        ? 'Aktifkan Kembali' 
                        : 'Arsipkan Kebiasaan',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kategori terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final habitNotifier = ref.read(habitsProvider.notifier);
      final categoryRepository = ref.read(categoryRepositoryProvider);
      
      // Debug: Print selected category info
      print('DEBUG: Saving habit with category: ${_selectedCategory?.name}');
      print('DEBUG: Selected category color: ${_selectedCategory?.color}');
      
      // Get category key using proper method
      final categoryKey = await categoryRepository.getCategoryKey(_selectedCategory!);
      
      print('DEBUG: Found category key: $categoryKey');
      
      // Debug: Print all field values being saved
      print('DEBUG: Saving habit with:');
      print('  - Title: ${_titleController.text.trim()}');
      print('  - Frequency: $_selectedFrequency');
      print('  - Timer Duration: $_timerDurationMinutes minutes');
      print('  - Has Notification: $_hasNotification');
      print('  - Notification Time: $_notificationTime');
      
      if (categoryKey == null) {
        throw Exception('Category not found: ${_selectedCategory?.name}');
      }

      bool success;

      if (widget.habitToEdit != null && widget.habitKey != null) {
        // Update existing habit
        final updatedHabit = Habit(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          categoryId: categoryKey,
          isArchived: widget.habitToEdit!.isArchived,
          createdDate: widget.habitToEdit!.createdDate,
          frequency: _selectedFrequency,
          timerDurationMinutes: _timerDurationMinutes,
          hasNotification: _hasNotification,
          notificationTime: _hasNotification && _notificationTime != null
              ? DateTime(2024, 1, 1, _notificationTime!.hour, _notificationTime!.minute)
              : null,
        );
        
        print('DEBUG: Created updatedHabit with timer: ${updatedHabit.timerDurationMinutes}');
        success = await habitNotifier.updateHabit(updatedHabit, widget.habitKey!);
      } else {
        // Create new habit
        final newHabit = Habit(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
              ? null 
              : _descriptionController.text.trim(),
          categoryId: categoryKey,
          frequency: _selectedFrequency,
          timerDurationMinutes: _timerDurationMinutes,
          hasNotification: _hasNotification,
          notificationTime: _hasNotification && _notificationTime != null
              ? DateTime(2024, 1, 1, _notificationTime!.hour, _notificationTime!.minute)
              : null,
        );
        
        print('DEBUG: Created newHabit with timer: ${newHabit.timerDurationMinutes}');
        success = await habitNotifier.addHabit(newHabit);
      }

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.habitToEdit != null 
                    ? 'Kebiasaan berhasil diperbarui'
                    : 'Kebiasaan berhasil ditambahkan',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.habitToEdit != null 
                    ? 'Gagal memperbarui kebiasaan'
                    : 'Gagal menambahkan kebiasaan',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _archiveHabit() async {
    if (widget.habitKey == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final habitNotifier = ref.read(habitsProvider.notifier);
      final success = await habitNotifier.archiveHabit(
        widget.habitKey!,
        !widget.habitToEdit!.isArchived,
      );

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.habitToEdit!.isArchived 
                    ? 'Kebiasaan berhasil diaktifkan kembali'
                    : 'Kebiasaan berhasil diarsipkan',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal mengubah status arsip'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showTemplateSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _buildTemplateSelector(scrollController),
      ),
    );
  }

  Widget _buildTemplateSelector(ScrollController scrollController) {
    final templates = TemplateService.getDefaultTemplates();
    final categories = ['Semua', ...TemplateService.getAllCategories()];
    
    return StatefulBuilder(
      builder: (context, setModalState) {
        String selectedCategory = 'Semua';
        final filteredTemplates = selectedCategory == 'Semua'
            ? templates
            : TemplateService.getTemplatesByCategory(selectedCategory);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              
              // Title
              Text(
                'Pilih Template Kebiasaan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Category Filter
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category == selectedCategory;
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            selectedCategory = category;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Templates List
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: filteredTemplates.length,
                  itemBuilder: (context, index) {
                    final template = filteredTemplates[index];
                    return _buildTemplateItem(context, template);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTemplateItem(BuildContext context, HabitTemplate template) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _useTemplate(template),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(template.color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  AppIcons.getIcon(template.icon),
                  color: Color(template.color),
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      template.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildTemplateChip(context, template.category, Color(template.color)),
                        const SizedBox(width: 4),
                        _buildTemplateChip(context, template.difficulty, _getDifficultyColor(template.difficulty)),
                      ],
                    ),
                  ],
                ),
              ),
              
              const Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 10,
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _useTemplate(HabitTemplate template) async {
    Navigator.of(context).pop(); // Close template selector
    
    print('DEBUG: Using template: ${template.title} with category: ${template.category}');
    
    // Fill form with template data
    setState(() {
      _titleController.text = template.title;
      _descriptionController.text = template.description;
    });
    
    // Load template category and wait for it to complete
    await _loadTemplateCategory(template);
    
    // Small delay to ensure UI updates
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Template "${template.title}" berhasil dimuat'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildFrequencySelector() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.repeat, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Frekuensi Kebiasaan',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...HabitFrequency.values.map((frequency) {
              return RadioListTile<HabitFrequency>(
                title: Text(frequency.displayName),
                subtitle: Text(
                  frequency.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                value: frequency,
                groupValue: _selectedFrequency,
                onChanged: (value) {
                  setState(() {
                    _selectedFrequency = value!;
                  });
                },
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timer, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Timer Tugas',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Aktifkan Timer'),
              subtitle: Text(
                _timerDurationMinutes != null 
                    ? 'Timer: $_timerDurationMinutes menit'
                    : 'Tidak ada timer',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              value: _timerDurationMinutes != null,
              onChanged: (value) {
                setState(() {
                  if (value) {
                    _timerDurationMinutes = 25; // Default 25 minutes (Pomodoro)
                  } else {
                    _timerDurationMinutes = null;
                  }
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            if (_timerDurationMinutes != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Durasi: $_timerDurationMinutes menit',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showTimerDurationPicker(),
                    icon: const Icon(Icons.edit),
                    tooltip: 'Ubah durasi',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Notifikasi',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Aktifkan Notifikasi'),
              subtitle: Text(
                _hasNotification && _notificationTime != null
                    ? 'Pengingat: ${_notificationTime!.format(context)}'
                    : 'Tidak ada pengingat',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              value: _hasNotification,
              onChanged: (value) {
                setState(() {
                  _hasNotification = value;
                  if (value && _notificationTime == null) {
                    _notificationTime = const TimeOfDay(hour: 9, minute: 0);
                  }
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            if (_hasNotification) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Waktu: ${_notificationTime?.format(context) ?? 'Belum diatur'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showTimePicker(),
                    icon: const Icon(Icons.access_time),
                    tooltip: 'Pilih waktu',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showTimerDurationPicker() async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Durasi Timer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('1 menit (Testing)'),
              onTap: () => Navigator.of(context).pop(1),
            ),
            ListTile(
              title: const Text('15 menit'),
              onTap: () => Navigator.of(context).pop(15),
            ),
            ListTile(
              title: const Text('25 menit (Pomodoro)'),
              onTap: () => Navigator.of(context).pop(25),
            ),
            ListTile(
              title: const Text('30 menit'),
              onTap: () => Navigator.of(context).pop(30),
            ),
            ListTile(
              title: const Text('45 menit'),
              onTap: () => Navigator.of(context).pop(45),
            ),
            ListTile(
              title: const Text('60 menit'),
              onTap: () => Navigator.of(context).pop(60),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() {
        _timerDurationMinutes = result;
      });
    }
  }

  Future<void> _showTimePicker() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _notificationTime ?? const TimeOfDay(hour: 9, minute: 0),
    );

    if (time != null) {
      setState(() {
        _notificationTime = time;
      });
    }
  }
}