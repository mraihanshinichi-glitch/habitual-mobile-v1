import 'dart:async';
import '../models/habit_timer.dart';

class TimerService {
  static final TimerService _instance = TimerService._internal();
  factory TimerService() => _instance;
  TimerService._internal();

  final Map<int, HabitTimer> _activeTimers = {};
  final StreamController<Map<int, HabitTimer>> _timersController = 
      StreamController<Map<int, HabitTimer>>.broadcast();

  Stream<Map<int, HabitTimer>> get timersStream => _timersController.stream;
  Map<int, HabitTimer> get activeTimers => Map.unmodifiable(_activeTimers);

  HabitTimer? getTimer(int habitKey) => _activeTimers[habitKey];

  bool hasActiveTimer(int habitKey) => _activeTimers.containsKey(habitKey);

  HabitTimer createTimer({
    required int habitKey,
    required int durationMinutes,
    Function(int remainingSeconds)? onTick,
    Function()? onCompleted,
  }) {
    // Stop existing timer if any
    stopTimer(habitKey);

    final timer = HabitTimer(
      habitKey: habitKey,
      durationMinutes: durationMinutes,
      onTick: (remainingSeconds) {
        onTick?.call(remainingSeconds);
        _notifyListeners();
      },
      onCompleted: () {
        onCompleted?.call();
        _removeTimer(habitKey);
      },
      onStarted: () => _notifyListeners(),
      onPaused: () => _notifyListeners(),
      onResumed: () => _notifyListeners(),
    );

    _activeTimers[habitKey] = timer;
    _notifyListeners();
    return timer;
  }

  void startTimer(int habitKey) {
    final timer = _activeTimers[habitKey];
    timer?.start();
  }

  void pauseTimer(int habitKey) {
    final timer = _activeTimers[habitKey];
    timer?.pause();
  }

  void resumeTimer(int habitKey) {
    final timer = _activeTimers[habitKey];
    timer?.resume();
  }

  void stopTimer(int habitKey) {
    final timer = _activeTimers[habitKey];
    if (timer != null) {
      timer.dispose();
      _removeTimer(habitKey);
    }
  }

  void stopAllTimers() {
    for (final timer in _activeTimers.values) {
      timer.dispose();
    }
    _activeTimers.clear();
    _notifyListeners();
  }

  void _removeTimer(int habitKey) {
    final timer = _activeTimers.remove(habitKey);
    timer?.dispose();
    _notifyListeners();
  }

  void _notifyListeners() {
    _timersController.add(Map.unmodifiable(_activeTimers));
  }

  void dispose() {
    stopAllTimers();
    _timersController.close();
  }
}