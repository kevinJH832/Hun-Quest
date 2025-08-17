import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

class TimerState extends ChangeNotifier {
  // 타이머 상태 변수들
  Timer? _timer;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  bool _isTimerRunning = false;
  bool _isBreakTime = false;
  bool _isPaused = false;
  int _focusMinutes = 25;
  int _breakMinutes = 5;
  String _timerMode = '';

  final AudioPlayer _audioPlayer = AudioPlayer();

  // Getter들 (다른 곳에서 상태 읽기용)
  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => _totalSeconds;
  bool get isTimerRunning => _isTimerRunning;
  bool get isBreakTime => _isBreakTime;
  bool get isPaused => _isPaused;
  int get focusMinutes => _focusMinutes;
  int get breakMinutes => _breakMinutes;
  String get timerMode => _timerMode;

  // 완료 시 호출할 콜백
  Function(int)? onTimerComplete;

  // 생성자
  TimerState({this.onTimerComplete});

  // 메모리 정리
  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  // 시간 포맷팅
  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // 30분 타이머 시작
  void startPomodoroTimer30() {
    _focusMinutes = 25;
    _breakMinutes = 5;
    _startPomodoroFocus();
  }

  // 60분 타이머 시작
  void startPomodoroTimer60() {
    _focusMinutes = 50;
    _breakMinutes = 10;
    _startPomodoroFocus();
  }

  // 집중 시간 시작
  void _startPomodoroFocus() async {
    // UI 상태 업데이트
    _isBreakTime = false;
    _totalSeconds = _focusMinutes * 60;
    _remainingSeconds = _totalSeconds;
    _isTimerRunning = true;
    _timerMode = '집중';
    notifyListeners(); // 상태 변경 알림!

    try {
      await _audioPlayer.play(AssetSource('sound/Timer_Start.mp3'));
      print('시작');

      await Future.delayed(Duration(milliseconds: 2600));
      await _audioPlayer.stop();

      _timerMode = '집중';
      notifyListeners();
      print('집중 시작! ⏰');
      _startTimerCountdown();
    } catch (e) {
      print('사운드 재생 실패: $e');
    }
  }

  // 휴식 시간 시작
  void _startPomodoroBreak() async {
    SystemSound.play(SystemSoundType.alert);
    print('휴식 시간! 🌿');

    _isBreakTime = true;
    _totalSeconds = _breakMinutes * 60;
    _remainingSeconds = _totalSeconds;
    notifyListeners();

    _startTimerCountdown();
  }

  // 일시정지/재개
  void pauseResumeTimer() {
    if (_isPaused) {
      print('타이머 시작');
      _startTimerCountdown();
      _isPaused = false;
    } else {
      print("정지!");
      _timer?.cancel();
      _isPaused = true;
    }
    notifyListeners();
  }

  // 타이머 카운트다운
  void _startTimerCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners(); // 매초마다 UI 업데이트!
      } else {
        // 타이머 완료!
        _timer?.cancel();

        if (_isBreakTime) {
          // 휴식 완료 -> 뽀모도로 끝!
          _completePomodoroSession();
        } else {
          // 집중 완료 -> 휴식 시작
          _startPomodoroBreak();
        }
      }
    });
  }

  // 뽀모도로 세션 완료
  void _completePomodoroSession() async {
    SystemSound.play(SystemSoundType.alert);
    print('뽀모도로 완료! 🎉');

    _isTimerRunning = false;
    _isBreakTime = false;
    notifyListeners();

    // 완료 콜백 호출
    onTimerComplete?.call(_focusMinutes);
  }

  void terminateTimer() {
    int actualFocusSeconds = _totalSeconds - _remainingSeconds;
    int actualFocusMinutes = actualFocusSeconds ~/ 60;

    print('실제 집중한 시간: $actualFocusMinutes분');

    _timer?.cancel();
    _isTimerRunning = false;
    _isBreakTime = false;
    _isPaused = false;
    _remainingSeconds = 0;
    notifyListeners();

    if (actualFocusMinutes > 0) {
      onTimerComplete?.call(actualFocusMinutes);
    }
  }
}
