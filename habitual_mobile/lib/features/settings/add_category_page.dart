import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/category.dart';
import '../../shared/providers/category_provider.dart';
import '../../core/constants/app_icons.dart';
import '../../core/constants/app_colors.dart';

class AddCategoryPage extends ConsumerStatefulWidget {
  final Category? categoryToEdit;

  const AddCategoryPage({super.key, this.categoryToEdit});

  @override
  ConsumerState<AddCategoryPage> createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends ConsumerState<AddCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  String _selectedIcon = 'category';
  Color _selectedColor = AppColors.categoryColors[0];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.categoryToEdit != null) {
      _nameController.text = widget.categoryToEdit!.name;
      _selectedIcon = widget.categoryToEdit!.icon;
      _selectedColor = Color(widget.categoryToEdit!.color);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.categoryToEdit != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Kategori' : 'Tambah Kategori'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Preview
            _buildPreview(),
            
            const SizedBox(height: 24),

            // Name field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Kategori',
                hintText: 'Contoh: Kesehatan, Belajar, Kerja',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.label),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama kategori tidak boleh kosong';
                }
                if (value.trim().length < 2) {
                  return 'Nama kategori minimal 2 karakter';
                }
                return null;
              },
              textInputAction: TextInputAction.done,
              onChanged: (value) => setState(() {}),
            ),

            const SizedBox(height: 24),

            // Icon selector
            _buildIconSelector(),

            const SizedBox(height: 24),

            // Color selector
            _buildColorSelector(),

            const SizedBox(height: 32),

            // Save button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveCategory,
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
                        isEditing ? 'Perbarui Kategori' : 'Simpan Kategori',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _selectedColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    AppIcons.getIcon(_selectedIcon),
                    color: _selectedColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _nameController.text.isEmpty 
                        ? 'Nama Kategori'
                        : _nameController.text,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _nameController.text.isEmpty 
                          ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Ikon',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: AppIcons.availableIcons.length,
              itemBuilder: (context, index) {
                final iconName = AppIcons.availableIcons[index];
                final isSelected = iconName == _selectedIcon;
                
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = iconName),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? _selectedColor.withOpacity(0.1)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected 
                            ? _selectedColor
                            : Theme.of(context).colorScheme.outline,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      AppIcons.getIcon(iconName),
                      color: isSelected 
                          ? _selectedColor
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      size: 24,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Warna',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: AppColors.categoryColors.length,
              itemBuilder: (context, index) {
                final color = AppColors.categoryColors[index];
                final isSelected = color.value == _selectedColor.value;
                
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected 
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final categoryNotifier = ref.read(categoryProvider.notifier);
      bool success;

      if (widget.categoryToEdit != null) {
        // Update existing category
        final updatedCategory = Category(
          name: _nameController.text.trim(),
          color: _selectedColor.value,
          icon: _selectedIcon,
        );
        updatedCategory.createdAt = widget.categoryToEdit!.createdAt;

        success = await categoryNotifier.updateCategory(updatedCategory);
      } else {
        // Create new category
        final newCategory = Category(
          name: _nameController.text.trim(),
          color: _selectedColor.value,
          icon: _selectedIcon,
        );

        success = await categoryNotifier.addCategory(newCategory);
      }

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.categoryToEdit != null 
                    ? 'Kategori berhasil diperbarui'
                    : 'Kategori berhasil ditambahkan',
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.categoryToEdit != null 
                    ? 'Gagal memperbarui kategori'
                    : 'Kategori dengan nama tersebut sudah ada',
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
}