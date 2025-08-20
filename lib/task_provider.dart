import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'task_model.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  TaskFilter _currentFilter = TaskFilter.all;
  String _searchQuery = '';
  static const String _tasksKey = 'pocket_tasks_v1';

  List<Task> get tasks => _tasks;
  TaskFilter get currentFilter => _currentFilter;
  String get searchQuery => _searchQuery;

  List<Task> get filteredTasks {
    Iterable<Task> filtered = _tasks;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((task) =>
          task.title.toLowerCase().contains(_searchQuery.toLowerCase()));
    }
    switch (_currentFilter) {
      case TaskFilter.active:
        filtered = filtered.where((task) => !task.isCompleted);
        break;
      case TaskFilter.done:
        filtered = filtered.where((task) => task.isCompleted);
        break;
      case TaskFilter.all:
        break;
    }
    return filtered.toList();
  }

  double get completionProgress {
    if (_tasks.isEmpty) {
      return 0.0;
    }
    final completedCount = _tasks.where((task) => task.isCompleted).length;
    return completedCount / _tasks.length;
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_tasksKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      _tasks = jsonList.map((json) => Task.fromJson(json)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _tasks.map((task) => task.toJson()).toList();
    await prefs.setString(_tasksKey, json.encode(jsonList));
  }

  void addTask(Task task) {
    _tasks.add(task);
    _saveTasks();
    notifyListeners();
  }

  void removeTask(Task task) {
    _tasks.removeWhere((t) => t.id == task.id);
    _saveTasks();
    notifyListeners();
  }

  void toggleTaskCompletion(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      _saveTasks();
      notifyListeners();
    }
  }

  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}