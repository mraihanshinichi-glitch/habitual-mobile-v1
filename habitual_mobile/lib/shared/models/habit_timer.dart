import 'dart:async';

enum TimerState {
  idle,     // Timer belum dimulai
  running,  // Timer sedang berjalan
  paused,   // Timer dijeda
  completed // Timer selesai
}

class HabitTimer {
  final int habitKey;
  final int durationMinutes;
  
  int _remainingSeconds;
  TimerState _state = TimerState.idle;
  Timer? _timer;
  
  // Callbacks
  Function(int remainingSeconds)? onTick;
  Function()? onCompleted;
  Function()? onStarted;
  Function()? onPaused;
  Function()? onResumed;

  HabitTimer({
    required this.habitKey,
    required this.durationMinutes,
    this.onTick,
    this.onCompleted,
    this.onStarted,
    this.onPaused,
    this.onResumed,
  }) : _remainingSeconds = durationMinutes * 60;

  // Getters
  TimerState get state => _state;
  int get remainingSeconds => _remainingSeconds;
  int get remainingMinutes => (_remainingSeconds / 60).ceil();
  double get progress => 1.0 - (_remainingSeconds / (durationMinutes * 60));
  bool get isRunning => _state == TimerState.running;
  bool get isPaused => _state == TimerState.paused;
  bool get isCompleted => _state == TimerState.completed;
  bool get canStart => _state == TimerState.idle || _state == TimerState.paused;
  bool get canPause => _state == TimerState.running;

  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Timer controls
  void start() {
    if (!canStart) return;
    
    _state = TimerState.running;
    onStarted?.call();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        onTick?.call(_remainingSeconds);
        
        // Debug logging for last 5 seconds
        if (_remainingSeconds <= 5) {
          print('DEBUG HabitTimer: ${_remainingSeconds} seconds remaining for habitKey $habitKey');
        }
      } else {
        print('DEBUG HabitTimer: Timer reached 0, completing for habitKey $habitKey');
        _complete();
      }
    });
  }

  void pause() {
    if (!canPause) return;
    
    _timer?.cancel();
    _state = TimerState.paused;
    onPaused?.call();
  }

  void resume() {
    if (_state != TimerState.paused) return;
    
    start(); // Reuse start logic
    onResumed?.call();
  }

  void stop() {
    _timer?.cancel();
    _state = TimerState.idle;
    _remainingSeconds = durationMinutes * 60;
  }

  void _complete() {
    print('DEBUG HabitTimer: Timer completing for habitKey $habitKey');
    _timer?.cancel();
    _state = TimerState.completed;
    _remainingSeconds = 0;
    print('DEBUG HabitTimer: Calling onCompleted callback for habitKey $habitKey');
    onCompleted?.call();
    print('DEBUG HabitTimer: onCompleted callback called for habitKey $habitKey');
  }

  void dispose() {
    _timer?.cancel();
  }
}