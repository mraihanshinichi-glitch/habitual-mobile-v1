import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../shared/providers/stats_provider.dart';
import '../../shared/providers/habit_provider.dart';
import '../../shared/providers/daily_progress_provider.dart';
import '../../shared/repositories/habit_repository.dart';
import '../../shared/repositories/habit_log_repository.dart';
import '../../core/constants/app_colors.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    
    // Listen to habit changes to refresh stats
    ref.listen(habitsProvider, (previous, next) {
      // Refresh stats when habits change
      ref.read(statsProvider.notifier).refreshStats();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(statsProvider.notifier).refreshStats();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: statsAsync.when(
        data: (statsData) => _buildStatsContent(context, statsData),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, ref, error),
      ),
    );
  }

  Widget _buildStatsContent(BuildContext context, StatsData statsData) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh will be handled by the provider
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary Cards
          _buildSummaryCards(context, statsData),
          
          const SizedBox(height: 24),
          
          // Progress Bar Section
          _buildProgressSection(context, statsData),
          
          const SizedBox(height: 24),
          
          // Category Distribution Chart
          if (statsData.categoryStats.isNotEmpty) ...[
            _buildSectionTitle(context, 'Distribusi per Kategori'),
            const SizedBox(height: 16),
            _buildCategoryChart(context, statsData.categoryStats),
            const SizedBox(height: 24),
          ],
          
          // Category List
          if (statsData.categoryStats.isNotEmpty) ...[
            _buildSectionTitle(context, 'Detail Kategori'),
            const SizedBox(height: 16),
            _buildCategoryList(context, statsData.categoryStats),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, StatsData statsData) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            'Total',
            statsData.totalCompletions.toString(),
            Icons.check_circle,
            AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context,
            'Minggu Ini',
            statsData.thisWeekCompletions.toString(),
            Icons.date_range,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            context,
            'Bulan Ini',
            statsData.thisMonthCompletions.toString(),
            Icons.calendar_month,
            AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildCategoryChart(BuildContext context, Map<String, int> categoryStats) {
    if (categoryStats.isEmpty) {
      return const SizedBox.shrink();
    }

    final sections = categoryStats.entries.map((entry) {
      final index = categoryStats.keys.toList().indexOf(entry.key);
      final color = AppColors.categoryColors[index % AppColors.categoryColors.length];
      
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${entry.value}',
        color: color,
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, Map<String, int> categoryStats) {
    final sortedEntries = categoryStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sortedEntries.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = sortedEntries[index];
          final colorIndex = categoryStats.keys.toList().indexOf(entry.key);
          final color = AppColors.categoryColors[colorIndex % AppColors.categoryColors.length];
          
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.category,
                color: color,
                size: 20,
              ),
            ),
            title: Text(entry.key),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${entry.value}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressSection(BuildContext context, StatsData statsData) {
    return Consumer(
      builder: (context, ref, child) {
        return ref.watch(dailyProgressProvider).when(
          data: (progressData) {
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Progress Hari Ini',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${progressData.completedHabits} dari ${progressData.totalHabits} kebiasaan selesai',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: progressData.progress,
                                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getProgressColor(progressData.progress),
                                ),
                                minHeight: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getProgressColor(progressData.progress).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${(progressData.progress * 100).round()}%',
                            style: TextStyle(
                              color: _getProgressColor(progressData.progress),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (progressData.totalHabits > 0) ...[
                      const SizedBox(height: 12),
                      Text(
                        _getProgressMessage(progressData.progress),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Error loading progress: $error'),
            ),
          ),
        );
      },
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return Colors.green;
    if (progress >= 0.5) return Colors.orange;
    return Colors.red;
  }

  String _getProgressMessage(double progress) {
    if (progress >= 1.0) return 'Luar biasa! Semua kebiasaan hari ini sudah selesai! 🎉';
    if (progress >= 0.8) return 'Hampir selesai! Tinggal sedikit lagi! 💪';
    if (progress >= 0.5) return 'Bagus! Kamu sudah di tengah jalan! 👍';
    if (progress > 0) return 'Mulai yang bagus! Terus semangat! 🚀';
    return 'Ayo mulai hari ini dengan menyelesaikan kebiasaan pertama! ✨';
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
              'Gagal memuat statistik',
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
              onPressed: () {
                ref.read(statsProvider.notifier).refreshStats();
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}