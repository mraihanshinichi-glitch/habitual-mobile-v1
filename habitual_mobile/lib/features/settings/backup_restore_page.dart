import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/services/simple_backup_service.dart';
import '../../shared/providers/habit_provider.dart';
import '../../shared/providers/category_provider.dart';
import '../../shared/providers/stats_provider.dart';
import '../../core/database/database_service.dart';

class BackupRestorePage extends ConsumerStatefulWidget {
  const BackupRestorePage({super.key});

  @override
  ConsumerState<BackupRestorePage> createState() => _BackupRestorePageState();
}

class _BackupRestorePageState extends ConsumerState<BackupRestorePage> {
  final SimpleBackupService _backupService = SimpleBackupService();
  bool _isLoading = false;
  List<String> _availableBackups = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableBackups();
  }

  Future<void> _loadAvailableBackups() async {
    final backups = await _backupService.getAvailableBackups();
    if (mounted) {
      setState(() {
        _availableBackups = backups;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Backup Section
          _buildSectionTitle(context, 'Backup Data'),
          Card(
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
                    'Cadangkan Data',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Buat cadangan semua data kebiasaan, kategori, dan log penyelesaian Anda.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _createBackup,
                      icon: _isLoading 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.backup),
                      label: Text(_isLoading ? 'Membuat Backup...' : 'Buat Backup'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Restore Section
          _buildSectionTitle(context, 'Restore Data'),
          Card(
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
                    'Pulihkan Data',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pulihkan data dari file backup. Perhatian: Ini akan mengganti semua data yang ada.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _restoreFromBackup,
                      icon: _isLoading 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.restore),
                      label: const Text('Pulihkan dari Backup'),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: _showBackupInfo,
                      icon: const Icon(Icons.info_outline),
                      label: const Text('Info Backup'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Delete Data Section
          _buildSectionTitle(context, 'Hapus Data'),
          Card(
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
                    'Hapus Semua Data',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hapus semua data aplikasi termasuk kebiasaan, kategori, dan log penyelesaian. Tindakan ini tidak dapat dibatalkan.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _deleteAllData,
                      icon: _isLoading 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.delete_forever, color: Colors.red),
                      label: const Text(
                        'Hapus Semua Data',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _resetToDefault,
                      icon: _isLoading 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh, color: Colors.orange),
                      label: const Text(
                        'Reset ke Default',
                        style: TextStyle(color: Colors.orange),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.orange),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Info Section
          Card(
            elevation: 1,
            color: Theme.of(context).colorScheme.primaryContainer,
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
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Informasi Penting',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• File backup disimpan di folder Download (mudah diakses via file manager)\n'
                    '• Backup berformat JSON dan dapat dibuka di aplikasi lain\n'
                    '• Backup mencakup semua kebiasaan, kategori, dan log penyelesaian\n'
                    '• Restore akan mengganti semua data yang ada\n'
                    '• Hapus Data akan menghapus semua data tanpa backup\n'
                    '• Reset ke Default akan mengembalikan kategori default\n'
                    '• Disarankan membuat backup secara berkala\n'
                    '• File backup dapat dibagikan atau dipindahkan ke perangkat lain\n'
                    '• Nama file: habitual_backup_[timestamp].json',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Future<void> _createBackup() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final filePath = await _backupService.createBackupFile();
      
      if (mounted && filePath != null) {
        await _loadAvailableBackups(); // Refresh backup list
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup berhasil disimpan: ${filePath.split('/').last}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat backup: $e'),
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

  Future<void> _restoreFromBackup() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Pick the most recent backup file
      final backupPath = await _backupService.pickBackupFile();
      
      if (backupPath == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak ada file backup yang ditemukan'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Read backup file
      final backup = await _backupService.readBackupFromPath(backupPath);
      
      if (backup != null) {
        final stats = await _backupService.getBackupStats(backup);
        
        if (mounted) {
          final confirmed = await _showRestoreConfirmation(stats, backupPath);
          
          if (confirmed == true) {
            await _backupService.restoreFromBackup(backup);
            
            // Refresh all providers
            ref.invalidate(habitsProvider);
            ref.invalidate(categoryProvider);
            ref.invalidate(statsProvider);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data berhasil dipulihkan dari backup'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 4),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memulihkan backup: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
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

  Future<void> _deleteAllData() async {
    final confirmed = await _showDeleteConfirmation();
    
    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Clear all data from database
      final databaseService = DatabaseService.instance;
      await databaseService.initialize();
      
      await databaseService.categoriesBox.clear();
      await databaseService.habitsBox.clear();
      await databaseService.habitLogsBox.clear();
      
      // Refresh all providers
      ref.invalidate(habitsProvider);
      ref.invalidate(categoryProvider);
      ref.invalidate(statsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua data berhasil dihapus'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus data: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
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

  Future<void> _resetToDefault() async {
    final confirmed = await _showResetConfirmation();
    
    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Reset database to default state
      final databaseService = DatabaseService.instance;
      await databaseService.resetDatabase();
      
      // Refresh all providers
      ref.invalidate(habitsProvider);
      ref.invalidate(categoryProvider);
      ref.invalidate(statsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil direset ke pengaturan default'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mereset data: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
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

  void _showBackupInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Info Backup'),
        content: const Text(
          'File backup disimpan di lokasi yang dapat diakses via file manager:\n\n'
          'Lokasi prioritas:\n'
          '1. Folder Download (paling mudah diakses)\n'
          '2. Android/data/[app]/files/ (jika tersedia)\n'
          '3. Folder Documents aplikasi (fallback)\n\n'
          'File backup berisi:\n'
          '• Semua kebiasaan (aktif & arsip)\n'
          '• Semua kategori (default & kustom)\n'
          '• Semua log penyelesaian\n'
          '• Metadata (timestamp, versi)\n\n'
          'File backup berformat JSON dan dapat:\n'
          '• Dibuka di aplikasi lain\n'
          '• Dibagikan ke perangkat lain\n'
          '• Diedit secara manual (untuk pengguna advanced)\n\n'
          'Nama file: habitual_backup_[timestamp].json',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showRestoreConfirmation(Map<String, int> stats, String filePath) {
    final fileName = filePath.split('/').last;
    
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Restore'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'File: $fileName',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'File backup berisi:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('• ${stats['categories']} kategori'),
            Text('• ${stats['habits']} kebiasaan'),
            Text('• ${stats['logs']} log penyelesaian'),
            const SizedBox(height: 16),
            const Text(
              'Perhatian: Semua data yang ada akan diganti dengan data dari backup. Tindakan ini tidak dapat dibatalkan.',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Pulihkan'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Hapus Semua Data',
          style: TextStyle(color: Colors.red),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Anda akan menghapus SEMUA data aplikasi:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Semua kebiasaan (aktif & arsip)'),
            Text('• Semua kategori (termasuk kustom)'),
            Text('• Semua log penyelesaian'),
            Text('• Semua statistik'),
            SizedBox(height: 16),
            Text(
              'PERINGATAN: Tindakan ini tidak dapat dibatalkan!',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Disarankan untuk membuat backup terlebih dahulu.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus Semua'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showResetConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Reset ke Default',
          style: TextStyle(color: Colors.orange),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reset akan menghapus semua data dan mengembalikan:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Kategori default (Kesehatan, Belajar, Kerja, Olahraga, Hobi)'),
            Text('• Menghapus semua kebiasaan'),
            Text('• Menghapus semua log penyelesaian'),
            Text('• Menghapus kategori kustom'),
            SizedBox(height: 16),
            Text(
              'Tindakan ini tidak dapat dibatalkan.',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Aplikasi akan kembali seperti baru diinstall.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }}
