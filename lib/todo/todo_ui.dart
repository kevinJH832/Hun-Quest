import 'package:flutter/material.dart';
import 'todo_state.dart';
import '../models/todo_item.dart';

class TodoWidget extends StatelessWidget {
  final TodoState todoState;

  const TodoWidget({super.key, required this.todoState});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        Text(
          "오늘 할 일",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),

        // 할일 목록 표시
        Expanded(
          child: todoState.todoList.isEmpty
              ? Center(child: Text("아직 할 일이 없어!\n + 버튼 눌러 추가해"))
              : ListView.builder(
                  itemCount: todoState.todoList.length,
                  itemBuilder: (context, index) {
                    return _buildTodoItem(
                      todoState.todoList[index],
                      index,
                      context,
                    );
                  },
                ),
        ),
      ],
    );
  }

  // TodoWidget 클래스 안에 추가

  Widget _buildTodoItem(TodoItem todo, int index, BuildContext context) {
    return GestureDetector(
      // 길게 누르면 삭제 확인 다이얼로그
      onLongPress: () => _showDeleteDialog(context, index),
      child: ListTile(
        // 체크박스
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (value) => todoState.toggleTodo(index),
        ),

        // 할일 제목
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted
                ? TextDecoration
                      .lineThrough // 완료되면 줄 그어짐
                : TextDecoration.none,
          ),
        ),

        // 할일 타입 표시 (아이콘)
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTypeIcon(todo.type),
            // 습관이면 요일도 표시
            if (todo.type == TodoType.habit && todo.habitDays != null)
              Text(
                ' ${_formatHabitDays(todo.habitDays!)}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  // 삭제 확인 다이얼로그
  void _showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('할 일 삭제'),
          content: Text('이 할 일을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                todoState.removeTodo(index);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  // 습관 요일 포맷팅
  String _formatHabitDays(List<int> days) {
    List<String> weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return days.map((day) => weekdays[day - 1]).join(',');
  }

  // 타입별 아이콘
  Widget _buildTypeIcon(TodoType type) {
    switch (type) {
      case TodoType.important:
        return Text('🔥');
      case TodoType.normal:
        return Text('📝');
      case TodoType.schedule:
        return Text('📅');
      case TodoType.habit:
        return Text('🔄');
    }
  }
}
