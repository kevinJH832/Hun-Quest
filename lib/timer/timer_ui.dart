import 'package:flutter/material.dart';
import 'timer_state.dart';

class TimerWidget extends StatelessWidget {
  final TimerState timerState; // TimerState를 받아옴!

  const TimerWidget({super.key, required this.timerState});

  @override
  Widget build(BuildContext context) {
    // TimerState의 상태를 사용
    if (timerState.isTimerRunning) {
      // 타이머 실행 중: 깔끔한 시간 표시만
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.withOpacity(0.1),
              Colors.black.withOpacity(0.05),
              Colors.deepPurple.withOpacity(0.1),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 현재 상태 표시
              Text(
                timerState.isBreakTime ? "휴식 시간" : "집중 시간",
                style: TextStyle(
                  fontSize: 24,
                  color: timerState.isBreakTime
                      ? Colors.green
                      : Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),

              SizedBox(height: 30),

              // 시간 표시 (크고 깔끔하게)
              Text(
                timerState.formatTime(timerState.remainingSeconds),
                style: TextStyle(
                  fontSize: 96,
                  fontWeight: FontWeight.bold,
                  color: timerState.isBreakTime
                      ? Colors.green
                      : Colors.deepPurple,
                  fontFamily: 'monospace',
                ),
              ),

              SizedBox(height: 20),

              // 진행 상황 표시
              Text(
                timerState.isBreakTime ? "잠시 쉬어가세요 🌿" : "집중하세요! 🔥",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  letterSpacing: 1,
                ),
              ),

              SizedBox(height: 50),

              // 진행률 바
              Container(
                width: 300,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: timerState.totalSeconds > 0
                        ? 1 -
                              (timerState.remainingSeconds /
                                  timerState.totalSeconds)
                        : 0,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      timerState.isBreakTime ? Colors.green : Colors.deepPurple,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 50),

              // 일시정지/재개 버튼
              // 기존 ElevatedButton 1개를 → Row로 2개 버튼!
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 일시정지/재개 버튼
                  ElevatedButton(
                    onPressed: timerState.pauseResumeTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ), // 조금 줄임
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      timerState.isPaused ? "시작" : "정지",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // 종료 버튼 (새로 추가!)
                  ElevatedButton(
                    onPressed: timerState.terminateTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600], // 빨간색!
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      "병신",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // 타이머 시작 전 화면
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 뽀모도로 아이콘
          Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.red.withOpacity(0.3),
                  Colors.deepOrange.withOpacity(0.1),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Text("🍅", style: TextStyle(fontSize: 80)),
          ),

          SizedBox(height: 30),

          Text(
            '뽀모도로 타이머',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),

          Text(
            'Pomodoro Technique',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              letterSpacing: 2,
            ),
          ),

          SizedBox(height: 40),

          // 타이머 선택 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 30분 뽀모도로 (25분+5분)
              _buildTimerButton(
                '🍅 30분',
                '25분 집중 + 5분 휴식',
                Colors.red,
                timerState.startPomodoroTimer30, // TimerState의 메서드!
              ),

              // 60분 뽀모도로 (50분+10분)
              _buildTimerButton(
                '🍅 60분',
                '50분 집중 + 10분 휴식',
                Colors.deepPurple,
                timerState.startPomodoroTimer60, // TimerState의 메서드!
              ),
            ],
          ),

          SizedBox(height: 30),
          Text(
            '료이키 텐카이! 버튼을 눌러 집중을 시작하세요',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 타이머 버튼 위젯
  Widget _buildTimerButton(
    String title,
    String subtitle,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.7), color.withOpacity(0.3)],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 5),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
