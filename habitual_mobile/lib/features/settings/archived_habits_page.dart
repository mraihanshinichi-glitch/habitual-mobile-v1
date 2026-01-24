import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/habit_provider.dart';
import '../../shared/widgets/habit_card.dart';

class ArchivedHabitsPage extends ConsumerWidget {
  const ArchivedHabitsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archivedHabitsAsync = ref.watch(archivedHabitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kebiasaan Terarsip'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: archivedHabitsAsync.when(
        data: (archivedHabits) {
          if (archivedHabits.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(archivedHabitsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: archivedHabits.length,
              itemBuilder: (context, index) {
                final habit = archivedHabits[index];
                final habitKey = habit.key ?? index;
                return HabitCard(
                  habitWithCategory: habit,
                  habitKey: habitKey,
                  onTap: () => _showHabitOptions(context, ref, habit, habitKey, index),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, ref, error),
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
              Icons.archive_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak ada kebiasaan terarsip',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Kebiasaan yang diarsipkan akan muncul di sini',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              'Gagal memuat data',
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
              onPressed: () => ref.invalidate(archivedHabitsProvider),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  void _showHabitOptions(BuildContext context, WidgetRef ref, habitWithCategory, int habitKey, int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              habitWithCategory.habit.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Options
            ListTile(
              leading: const Icon(Icons.unarchive),
              title: const Text('Aktifkan Kembali'),
              onTap: () {
                Navigator.of(context).pop();
                _unarchiveHabit(context, ref, habitKey, index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Hapus Permanen', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                _deleteHabitPermanently(context, ref, habitKey, index);
              },
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _unarchiveHabit(BuildContext context, WidgetRef ref, int habitKey, int index) async {
    try {
      // Try with habitKey first, then fallback to index
      bool success = await ref.read(habitsProvider.notifier).archiveHabit(habitKey, false);
      
      // If failed with habitKey, try with index
      if (!success && habitKey != index) {
        success = await ref.read(habitsProvider.notifier).archiveHabit(index, false);
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                  ? 'Kebiasaan berhasil diaktifkan kembali'
                  : 'Gagal mengaktifkan kebiasaan',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        
        if (success) {
          // Refresh both providers to update the lists
          ref.invalidate(archivedHabitsProvider);
          ref.invalidate(habitsProvider);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteHabitPermanently(BuildContext context, WidgetRef ref, int habitKey, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Permanen'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus kebiasaan ini secara permanen? '
          'Tindakan ini tidak dapat dibatalkan dan akan menghapus semua data terkait.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Try with habitKey first, then fallback to index
              bool success = await ref.read(habitsProvider.notifier).deleteHabit(habitKey);
              
              // If failed with habitKey, try with index
              if (!success && habitKey != index) {
                success = await ref.read(habitsProvider.notifier).deleteHabit(index);
              }
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success 
                          ? 'Kebiasaan berhasil dihapus permanen'
                          : 'Gagal menghapus kebiasaan',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
                
                if (success) {
                  ref.invalidate(archivedHabitsProvider);
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus Permanen'),
          ),
        ],
      ),
    );
  }
}