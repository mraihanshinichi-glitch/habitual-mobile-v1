import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/habit_repository.dart';
import '../providers/habit_provider.dart';
import '../providers/stats_provider.dart';
import '../providers/daily_progress_provider.dart';
import 'timer_widget.dart';
import '../../core/constants/app_icons.dart';

class HabitCard extends ConsumerStatefulWidget {
  final HabitWithCategory habitWithCategory;
  final int habitKey;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const HabitCard({
    super.key,
    required this.habitWithCategory,
    required this.habitKey,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  ConsumerState<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends ConsumerState<HabitCard> {
  bool _isCompleted = false;
  int _streak = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print('DEBUG HabitCard: Initializing for habit "${widget.habitWithCategory.habit.title}" with key ${widget.habitKey}');
    _loadHabitStatus();
  }

  Future<void> _loadHabitStatus() async {
    print('DEBUG: Loading habit status for habitKey: ${widget.habitKey}');
    final habitNotifier = ref.read(habitsProvider.notifier);
    final isCompleted = await habitNotifier.isHabitCompletedToday(widget.habitKey);
    final streak = await habitNotifier.getHabitStreak(widget.habitKey);
    
    print('DEBUG: Habit ${widget.habitKey} - isCompleted: $isCompleted, streak: $streak');
    
    if (mounted) {
      setState(() {
        _isCompleted = isCompleted;
        _streak = streak;
      });
    }
  }

  Future<void> _toggleCompletion() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    // Use daily progress provider for better state management
    final dailyProgressNotifier = ref.read(dailyProgressProvider.notifier);
    await dailyProgressNotifier.toggleHabitCompletion(widget.habitKey);
    
    // Also refresh habit status locally
    await _loadHabitStatus();
    
    // Refresh stats provider to update statistics
    ref.invalidate(statsProvider);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habit = widget.habitWithCategory.habit;
    final category = widget.habitWithCategory.category;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Category Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: category != null 
                      ? Color(category.color).withOpacity(0.1)
                      : theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  category != null 
                      ? AppIcons.getIcon(category.icon)
                      : Icons.category,
                  color: category != null 
                      ? Color(category.color)
                      : theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Habit Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: _isCompleted 
                            ? TextDecoration.lineThrough
                            : null,
                        color: _isCompleted 
                            ? theme.colorScheme.onSurface.withOpacity(0.6)
                            : null,
                      ),
                    ),
                    
                    if (habit.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        habit.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    const SizedBox(height: 8),
                    
                    // Category and Streak
                    Row(
                      children: [
                        if (category != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Color(category.color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              category.name,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Color(category.color),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        
                        if (_streak > 0) ...[
                          Icon(
                            Icons.local_fire_department,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$_streak',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    // Timer section (if habit has timer)
                    if (habit.hasTimer && !_isCompleted) ...[
                      const SizedBox(height: 8),
                      TimerWidget(
                        habitKey: widget.habitKey,
                        habitTitle: habit.title,
                        durationMinutes: habit.timerDurationMinutes ?? 25,
                        onCompleted: () {
                          // Mark habit as completed when timer finishes and user confirms
                          _toggleCompletion();
                        },
                        onTimerCompleted: () {
                          // Timer finished but user said not completed yet
                          // Just refresh the card state
                          _loadHabitStatus();
                        },
                      ),
                    ],
                  ],
                ),
              ),
              
              // Completion Checkbox
              _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Checkbox(
                      value: _isCompleted,
                      onChanged: (_) => _toggleCompletion(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
              
              // More options
              if (widget.onEdit != null || widget.onDelete != null)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        widget.onEdit?.call();
                        break;
                      case 'delete':
                        widget.onDelete?.call();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    if (widget.onEdit != null)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                    if (widget.onDelete != null)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}