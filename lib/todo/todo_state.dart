import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/todo_item.dart';

class TodoState extends ChangeNotifier {
  // 할일 리스트
  List<TodoItem> _todoList = [];

  // Getter (다른 곳에서 읽기용)
  List<TodoItem> get todoList => _todoList;

  // 생성자
  TodoState() {
    _loadTodos(); // 할일 불러오기
  }

  //할일 추가
  void addTodo(String title, TodoType type, {List<int>? habitDays}) {
    TodoItem newTodo = TodoItem(title: title, type: type, habitDays: habitDays);

    _todoList.add(newTodo);
    notifyListeners(); // UI에게 리스트변경 알림
    _saveTodos(); // 할일 저장하기
  }

  //할일 토글(체크박스)
  void toggleTodo(int index) {
    _todoList[index].isCompleted = !_todoList[index].isCompleted;
    notifyListeners();
    _saveTodos();
  }

  //할일 삭제
  void removeTodo(int index) {
    _todoList.removeAt(index);
    notifyListeners();
    _saveTodos();
  }

  // 저장하기
  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _todoList.map((todo) => todo.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString('todos', jsonString);
  }

  // 불러오기
  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('todos');
    if (jsonString != null) {
      final jsonList = jsonDecode(jsonString) as List;
      _todoList = jsonList.map((json) => TodoItem.fromJson(json)).toList();
      notifyListeners();
    }
  }
}
