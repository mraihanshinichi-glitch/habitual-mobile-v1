import 'package:flutter/material.dart';
import '../models/habit_timer.dart';
import '../services/timer_service.dart';

class TimerWidget extends StatefulWidget {
  final int habitKey;
  final String habitTitle;
  final int durationMinutes;
  final VoidCallback? onCompleted;
  final VoidCallback? onTimerCompleted;

  const TimerWidget({
    Key? key,
    required this.habitKey,
    required this.habitTitle,
    required this.durationMinutes,
    this.onCompleted,
    this.onTimerCompleted,
  }) : super(key: key);

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  final TimerService _timerService = TimerService();
  HabitTimer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = _timerService.getTimer(widget.habitKey);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          _buildTimerHeader(),
          const SizedBox(height: 8),
          _buildTimerDisplay(),
          const SizedBox(height: 8),
          _buildTimerControls(),
        ],
      ),
    );
  }

  Widget _buildTimerHeader() {
    return Row(
      children: [
        Icon(
          Icons.timer,
          color: Theme.of(context).colorScheme.primary,
          size: 16,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Timer: ${widget.durationMinutes} menit',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        _buildTimerStatus(),
      ],
    );
  }

  Widget _buildTimerStatus() {
    return StreamBuilder<Map<int, HabitTimer>>(
      stream: _timerService.timersStream,
      builder: (context, snapshot) {
        final timer = _timerService.getTimer(widget.habitKey);
        
        if (timer == null) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Siap',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _getTimerColor(timer.state).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _getTimerStatusText(timer.state),
            style: TextStyle(
              color: _getTimerColor(timer.state),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimerDisplay() {
    return StreamBuilder<Map<int, HabitTimer>>(
      stream: _timerService.timersStream,
      builder: (context, snapshot) {
        final timer = _timerService.getTimer(widget.habitKey);
        
        if (timer == null) {
          return Text(
            '${widget.durationMinutes.toString().padLeft(2, '0')}:00',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }
        
        return Column(
          children: [
            Text(
              timer.formattedTime,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getTimerColor(timer.state),
              ),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: timer.progress,
              backgroundColor: Colors.grey.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                _getTimerColor(timer.state),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimerControls() {
    return StreamBuilder<Map<int, HabitTimer>>(
      stream: _timerService.timersStream,
      builder: (context, snapshot) {
        final timer = _timerService.getTimer(widget.habitKey);
        
        if (timer == null) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _startTimer,
              icon: const Icon(Icons.play_arrow, size: 16),
              label: const Text('Mulai Timer'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          );
        }
        
        return Row(
          children: [
            if (timer.canStart) ...[ 
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: timer.state == TimerState.idle ? _startTimer : _resumeTimer,
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: Text(timer.state == TimerState.idle ? 'Mulai' : 'Lanjut'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
            if (timer.canPause) ...[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pauseTimer,
                  icon: const Icon(Icons.pause, size: 16),
                  label: const Text('Jeda'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
            if (timer.state != TimerState.idle) ...[
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _stopTimer,
                  icon: const Icon(Icons.stop, size: 16),
                  label: const Text('Stop'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: const BorderSide(color: Colors.red),
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _startTimer() {
    print('DEBUG TimerWidget: Starting timer for habit ${widget.habitKey}');
    
    // TEMPORARY: Use shorter duration for testing (10 seconds instead of minutes)
    final testDuration = widget.durationMinutes; // Change to 1 for 1 minute testing
    
    _timer = _timerService.createTimer(
      habitKey: widget.habitKey,
      durationMinutes: testDuration,
      onCompleted: () {
        print('DEBUG TimerWidget: Timer completed for habit ${widget.habitKey}');
        if (mounted) {
          print('DEBUG TimerWidget: Widget is mounted, showing completion dialog');
          _showCompletionDialog();
        } else {
          print('DEBUG TimerWidget: Widget not mounted, cannot show dialog');
        }
      },
    );
    
    _timerService.startTimer(widget.habitKey);
    print('DEBUG TimerWidget: Timer started for habit ${widget.habitKey} with duration ${testDuration} minutes');
  }

  void _pauseTimer() {
    _timerService.pauseTimer(widget.habitKey);
  }

  void _resumeTimer() {
    _timerService.resumeTimer(widget.habitKey);
  }

  void _stopTimer() {
    _timerService.stopTimer(widget.habitKey);
  }

  void _showCompletionDialog() {
    print('DEBUG TimerWidget: Showing completion dialog for habit ${widget.habitKey}');
    if (!mounted) {
      print('DEBUG TimerWidget: Widget not mounted, cannot show dialog');
      return;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.timer_off,
              color: Colors.green,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('Timer Selesai!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 48,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Timer ${widget.durationMinutes} menit untuk',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '"${widget.habitTitle}"',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'telah selesai!',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Apakah Anda sudah menyelesaikan kebiasaan ini?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('DEBUG TimerWidget: User selected "Belum Selesai"');
              Navigator.of(context).pop();
              _timerService.stopTimer(widget.habitKey);
              widget.onTimerCompleted?.call();
            },
            child: const Text('Belum Selesai'),
          ),
          ElevatedButton(
            onPressed: () {
              print('DEBUG TimerWidget: User selected "Sudah Selesai"');
              Navigator.of(context).pop();
              _timerService.stopTimer(widget.habitKey);
              widget.onCompleted?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sudah Selesai'),
          ),
        ],
      ),
    );
  }

  Color _getTimerColor(TimerState state) {
    switch (state) {
      case TimerState.idle:
        return Colors.grey;
      case TimerState.running:
        return Colors.green;
      case TimerState.paused:
        return Colors.orange;
      case TimerState.completed:
        return Colors.blue;
    }
  }

  String _getTimerStatusText(TimerState state) {
    switch (state) {
      case TimerState.idle:
        return 'Siap';
      case TimerState.running:
        return 'Berjalan';
      case TimerState.paused:
        return 'Dijeda';
      case TimerState.completed:
        return 'Selesai';
    }
  }

  @override
  void dispose() {
    // Don't stop timer on dispose - let it continue running
    super.dispose();
  }
}