// ignore_for_file: constant_identifier_names

enum ExecutionState { NOT_STARTED, PLAYING, PAUSED, FINISHED }

class ExecutionController {
  ExecutionController({
    this.onPlay,
    this.onPause,
    this.onFinish,
  });

  ExecutionState _currentState = ExecutionState.NOT_STARTED;
  DateTime? _endedAt;
  DateTime? _lastPausedAt;
  Duration _pausedDuration = Duration.zero;
  DateTime? _startedAt;

  Function()? onPlay;
  Function()? onPause;
  Function()? onFinish;

  // NOT_STARTED -> PLAYING
  void _startExecution() {
    if (_currentState == ExecutionState.NOT_STARTED) {
      _currentState = ExecutionState.PLAYING;
      _startedAt = DateTime.now();
      onPlay?.call();
    }
  }

  // PLAYING -> PAUSED
  void _pauseExecution() {
    if (_currentState == ExecutionState.PLAYING) {
      _currentState = ExecutionState.PAUSED;
      _lastPausedAt = DateTime.now();
      onPause?.call();
    }
  }

  // PAUSED/FINISHED -> PLAYING
  void _resumeExecution() {
    if (_currentState == ExecutionState.PAUSED) {
      _currentState = ExecutionState.PLAYING;
      if (_lastPausedAt != null) {
        _pausedDuration += DateTime.now().difference(_lastPausedAt!);
        _lastPausedAt = null;
      }
      onPlay?.call();
    } else if (_currentState == ExecutionState.FINISHED) {
      _lastPausedAt = _endedAt;
      _endedAt = null;
      _currentState = ExecutionState.PAUSED;
      _resumeExecution();
    }
  }

  // PLAYING -> FINISHED
  void _finishExecution() {
    _currentState = ExecutionState.FINISHED;
    _endedAt = DateTime.now();
    onFinish?.call();
  }

  // Getters for accessible properties
  DateTime? get startedAt => _startedAt;

  DateTime? get endedAt => _endedAt;

  // DateTime? get lastPausedAt => _lastPausedAt;

  Duration get duration {
    if (_startedAt != null) {
      if (_currentState == ExecutionState.PLAYING) {
        return DateTime.now().difference(_startedAt!) - _pausedDuration;
      } else if (_currentState == ExecutionState.PAUSED) {
        if (_lastPausedAt != null) {
          return _lastPausedAt!.difference(_startedAt!) - _pausedDuration;
        }
      } else if (_currentState == ExecutionState.FINISHED) {
        if (_endedAt != null) {
          return _endedAt!.difference(_startedAt!) - _pausedDuration;
        }
      }
    }
    return Duration.zero;
  }

  // Get the current state
  ExecutionState get currentState => _currentState;

  // * -> PLAYING
  void play() {
    if (_currentState == ExecutionState.NOT_STARTED) {
      _startExecution();
    } else {
      _resumeExecution();
    }
  }

  // * -> PAUSED
  void pause() {
    play();
    _pauseExecution();
  }

  // * -> FINISHED
  void finish() {
    play();
    _finishExecution();
  }

  void add(Duration d) {
    pause();
    _startedAt = _startedAt?.subtract(d);
  }

  bool get isStarted => _currentState != ExecutionState.NOT_STARTED;

  bool get isPlaying => _currentState == ExecutionState.PLAYING;

  bool get isStopped => _currentState != ExecutionState.PLAYING;

  bool get isPaused => _currentState == ExecutionState.PAUSED;

  bool get isFinished => _currentState == ExecutionState.FINISHED;
}
