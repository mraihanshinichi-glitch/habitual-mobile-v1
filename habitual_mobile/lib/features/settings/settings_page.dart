import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/theme_provider.dart';
import 'archived_habits_page.dart';
import 'categories_page.dart';
import 'backup_restore_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Info Section
          _buildSectionTitle(context, 'Aplikasi'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Tentang Aplikasi'),
                  subtitle: const Text('Habitual Mobile v1.0.0'),
                  onTap: () => _showAboutDialog(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Appearance Section
          _buildSectionTitle(context, 'Tampilan'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    final themeNotifier = ref.read(themeProvider.notifier);
                    return ListTile(
                      leading: Icon(themeNotifier.themeIcon),
                      title: const Text('Mode Tema'),
                      subtitle: Text('Saat ini: ${themeNotifier.themeName}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showThemeDialog(context, ref),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Data Management Section
          _buildSectionTitle(context, 'Manajemen Data'),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.archive_outlined),
                  title: const Text('Kebiasaan Terarsip'),
                  subtitle: const Text(
                    'Lihat dan kelola kebiasaan yang diarsipkan',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _navigateToArchivedHabits(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: const Text('Kelola Kategori'),
                  subtitle: const Text('Tambah, edit, atau hapus kategori'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _navigateToCategories(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.backup_outlined),
                  title: const Text('Backup & Restore'),
                  subtitle: const Text('Cadangkan dan pulihkan data kebiasaan'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _navigateToBackupRestore(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Footer
          Center(
            child: Text(
              'Dibuat dengan ❤️ menggunakan Flutter',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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

  void _navigateToArchivedHabits(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ArchivedHabitsPage()));
  }

  void _navigateToCategories(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CategoriesPage()));
  }

  void _navigateToBackupRestore(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const BackupRestorePage()));
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Mode Tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.light_mode),
              title: const Text('Terang'),
              onTap: () {
                ref.read(themeProvider.notifier).setTheme(ThemeMode.light);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Gelap'),
              onTap: () {
                ref.read(themeProvider.notifier).setTheme(ThemeMode.dark);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_auto),
              title: const Text('Ikuti Sistem'),
              onTap: () {
                ref.read(themeProvider.notifier).setTheme(ThemeMode.system);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Habitual Mobile',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.task_alt, size: 48),
      children: [
        const Text(
          'Aplikasi pelacak kebiasaan yang membantu Anda membangun rutinitas positif dan mencapai tujuan harian.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Fitur utama:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Text('• Manajemen kebiasaan (CRUD)'),
        const Text('• Sistem streak'),
        const Text('• Kategori kustom'),
        const Text('• Statistik dan grafik'),
        const Text('• Arsip kebiasaan'),
      ],
    );
  }
}
