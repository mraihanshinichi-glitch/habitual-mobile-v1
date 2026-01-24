import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../shared/providers/habit_provider.dart';
import '../../shared/widgets/habit_card.dart';
import 'add_habit_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);
    final today = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habitual'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hari ini',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  today,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // Habits list
          Expanded(
            child: habitsAsync.when(
              data: (habitsWithCategory) {
                // Filter only non-archived habits
                final activeHabits = habitsWithCategory
                    .where((hwc) => !hwc.habit.isArchived)
                    .toList();

                if (activeHabits.isEmpty) {
                  return _buildEmptyState(context);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(habitsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 16, bottom: 80),
                    itemCount: activeHabits.length,
                    itemBuilder: (context, index) {
                      final habitWithCategory = activeHabits[index];
                      final habitKey = habitWithCategory.key ?? index; // Use actual key if available
                      
                      return HabitCard(
                        habitWithCategory: habitWithCategory,
                        habitKey: habitKey,
                        onEdit: () => _editHabit(context, habitWithCategory, habitKey),
                        onDelete: () => _deleteHabit(context, ref, habitKey),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Terjadi kesalahan',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(habitsProvider),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addHabit(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum ada kebiasaan',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Mulai membangun kebiasaan baik dengan menambahkan kebiasaan pertama Anda',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _addHabit(context),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Kebiasaan'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addHabit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddHabitPage(),
      ),
    );
  }

  void _addHabitFromTemplate(BuildContext context, template) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddHabitPage(template: template),
      ),
    );
  }

  void _editHabit(BuildContext context, habitWithCategory, int habitKey) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddHabitPage(
          habitToEdit: habitWithCategory.habit,
          habitKey: habitKey,
        ),
      ),
    );
  }

  void _deleteHabit(BuildContext context, WidgetRef ref, int habitKey) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kebiasaan'),
        content: const Text('Apakah Anda yakin ingin menghapus kebiasaan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await ref.read(habitsProvider.notifier).deleteHabit(habitKey);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success 
                          ? 'Kebiasaan berhasil dihapus'
                          : 'Gagal menghapus kebiasaan',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}