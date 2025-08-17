import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'timer/timer_state.dart'; // 상태 관리
import 'timer/timer_ui.dart'; // UI 위젯

import 'todo/todo_state.dart';
import 'todo/todo_ui.dart';
import 'models/todo_item.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jaehun Quest',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Jaehun Quest'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  int _todayTimerCount = 0;
  int _todayFocusMinutes = 0;
  String _lastResetDate = '';

  late TimerState _timerState;
  late TodoState _todoState;

  void _checkDailyReset() {
    String today = DateTime.now().toString().substring(0, 10);
    if (_lastResetDate != today) {
      _todayTimerCount = 0;
      _todayFocusMinutes = 0;
      _lastResetDate = today;
      _saveTimerStats();
    }
  }

  void _onTimerComplete(int minutes) {
    setState(() {
      _todayTimerCount++;
      _todayFocusMinutes += minutes;
    });
    _saveTimerStats();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildTodayTab() {
    return ListenableBuilder(
      listenable: _todoState,
      builder: (context, child) {
        return TodoWidget(todoState: _todoState);
      },
    );
  }

  Widget _buildCalendarTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month, size: 100, color: Colors.blue),
          SizedBox(height: 20),
          Text('캘린더', style: TextStyle(fontSize: 24)),
          Text('(개발 예정)', style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildTimerTab() {
    return ListenableBuilder(
      listenable: _timerState, // TimerState의 변화를 감지!
      builder: (context, child) {
        return TimerWidget(timerState: _timerState);
      },
    );
  }

  Widget _buildStatsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 100, color: Colors.green),
          SizedBox(height: 20),
          Text('통계', style: TextStyle(fontSize: 24)),
          Text('(개발 예정)', style: TextStyle(fontSize: 16, color: Colors.grey)),
          SizedBox(height: 20),
          // 간단한 통계 표시
          Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.green.withOpacity(0.1),
            ),
            child: Column(
              children: [
                Text(
                  '오늘의 성과',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text('완료한 세션: $_todayTimerCount개'),
                Text('총 집중 시간: $_todayFocusMinutes분'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addTodo() {
    TextEditingController controller = TextEditingController();
    TodoType selectedType = TodoType.normal; // 기본값
    List<int> selectedHabitDays = []; // 습관용 요일들

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          // 다이얼로그 안에서 상태 변경을 위해 필요!
          builder: (context, setState) {
            return AlertDialog(
              title: Text('새로운 할 일 추가'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 할일 제목 입력
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(hintText: '할 일을 입력하세요'),
                  ),

                  SizedBox(height: 20),

                  // 타입 선택
                  Text('타입 선택:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),

                  // 타입 선택 버튼들
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTypeButton(
                        '🔥',
                        '중요',
                        TodoType.important,
                        selectedType,
                        (type) {
                          setState(() => selectedType = type);
                        },
                      ),
                      _buildTypeButton(
                        '📝',
                        '일반',
                        TodoType.normal,
                        selectedType,
                        (type) {
                          setState(() => selectedType = type);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTypeButton(
                        '📅',
                        '스케줄',
                        TodoType.schedule,
                        selectedType,
                        (type) {
                          setState(() => selectedType = type);
                        },
                      ),
                      _buildTypeButton(
                        '🔄',
                        '습관',
                        TodoType.habit,
                        selectedType,
                        (type) {
                          setState(() => selectedType = type);
                        },
                      ),
                    ],
                  ),

                  // 습관 타입일 때만 요일 선택 표시
                  if (selectedType == TodoType.habit) ...[
                    SizedBox(height: 20),
                    Text(
                      '요일 선택:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    _buildWeekdaySelector(selectedHabitDays, setState),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('취소'),
                ),
                TextButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      // 습관 타입이면서 요일이 선택되지 않았으면 에러
                      if (selectedType == TodoType.habit &&
                          selectedHabitDays.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('습관은 최소 1개 요일을 선택해주세요!')),
                        );
                        return;
                      }

                      _todoState.addTodo(
                        controller.text,
                        selectedType,
                        habitDays: selectedType == TodoType.habit
                            ? selectedHabitDays
                            : null,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: Text('추가'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveTimerStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('todayTimerCount', _todayTimerCount);
    await prefs.setInt('todayFocusMinutes', _todayFocusMinutes);
    await prefs.setString('lastResetDate', _lastResetDate);
  }

  Future<void> _loadTimerStats() async {
    final prefs = await SharedPreferences.getInstance();
    _todayTimerCount = prefs.getInt('todayTimerCount') ?? 0;
    _todayFocusMinutes = prefs.getInt('todayFocusMinutes') ?? 0;
    _lastResetDate = prefs.getString('lastResetDate') ?? '';
  }

  @override
  void initState() {
    super.initState();

    _timerState = TimerState(onTimerComplete: _onTimerComplete);
    _todoState = TodoState();

    _loadTimerStats();
    _checkDailyReset();
  }

  // 메모리 정리
  @override
  void dispose() {
    _timerState.dispose();
    _todoState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget currentTab;
    switch (_selectedIndex) {
      case 0:
        currentTab = _buildTodayTab();
        break;
      case 1:
        currentTab = _buildCalendarTab();
        break;
      case 2:
        currentTab = _buildTimerTab();
        break;
      case 3:
        currentTab = _buildStatsTab();
        break;
      default:
        currentTab = _buildTodayTab();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: currentTab,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.today), label: '오늘'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: '캘린더',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: '타이머'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: '통계'),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _addTodo,
              tooltip: '할 일 추가',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildTypeButton(
    String icon,
    String label,
    TodoType type,
    TodoType selectedType,
    Function(TodoType) onTap,
  ) {
    bool isSelected = selectedType == type;
    return GestureDetector(
      onTap: () => onTap(type),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Colors.deepPurple.withOpacity(0.1) : null,
        ),
        child: Column(
          children: [
            Text(icon, style: TextStyle(fontSize: 20)),
            Text(label, style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdaySelector(List<int> selectedDays, Function setState) {
    List<String> weekdays = ['월', '화', '수', '목', '금', '토', '일'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        int dayNumber = index + 1;
        bool isSelected = selectedDays.contains(dayNumber);

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                selectedDays.remove(dayNumber);
              } else {
                selectedDays.add(dayNumber);
              }
            });
          },
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: isSelected ? Colors.deepPurple : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                weekdays[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
