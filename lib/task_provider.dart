import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'task_model.dart';

class TaskProvider extends ChangeNotifier {
  static const storageKey = 'pocket_tasks_v1';

  final List<Task> _tasks = [];
  TaskFilter _filter = TaskFilter.all;
  String _query = '';
  Timer? _debounce;

  // Public getters
  List<Task> get tasks => List.unmodifiable(_tasks);
  TaskFilter get filter => _filter;
  String get query => _query;

  // Derived view: filtered + searched
  List<Task> get visibleTasks =>
      applyFilters(_tasks, filter: _filter, query: _query);

  int get totalCount => _tasks.length;
  int get doneCount => _tasks.where((t) => t.done).length;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw != null && raw.isNotEmpty) {
      final loaded = Task.decodeList(raw);
      _tasks
        ..clear()
        ..addAll(loaded);
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, Task.encodeList(_tasks));
  }

  Future<void> addTask(Task task) async {
    _tasks.insert(0, task);
    await _persist();
    notifyListeners();
  }

  /// Toggle returns the previous value so UI can offer Undo.
  Future<bool> toggleTask(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return false;
    final prev = _tasks[idx];
    _tasks[idx] = prev.copyWith(done: !prev.done);
    await _persist();
    notifyListeners();
    return prev.done; // return previous state for undo
  }

  /// Delete returns (deletedTask, index) for Undo.
  Future<(Task?, int)> deleteTask(String id) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return (null, -1);
    final removed = _tasks.removeAt(idx);
    await _persist();
    notifyListeners();
    return (removed, idx);
  }

  Future<void> undoToggle(String id, bool previousValue) async {
    final idx = _tasks.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    _tasks[idx] = _tasks[idx].copyWith(done: previousValue);
    await _persist();
    notifyListeners();
  }

  Future<void> undoDelete(Task task, int index) async {
    if (index < 0 || index > _tasks.length) {
      _tasks.insert(0, task);
    } else {
      _tasks.insert(index, task);
    }
    await _persist();
    notifyListeners();
  }

  void setFilter(TaskFilter value) {
    if (_filter == value) return;
    _filter = value;
    notifyListeners();
  }

  /// Debounced (300ms) search query setter
  void setQuery(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _query = value;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// Pure helper used by tests, does not touch persistence.
  static List<Task> applyFilters(List<Task> input,
      {TaskFilter filter = TaskFilter.all, String query = ''}) {
    final q = query.trim().toLowerCase();
    Iterable<Task> out = input;

    if (q.isNotEmpty) {
      out = out.where((t) => t.title.toLowerCase().contains(q));
    }
    switch (filter) {
      case TaskFilter.all:
        break;
      case TaskFilter.active:
        out = out.where((t) => !t.done);
        break;
      case TaskFilter.done:
        out = out.where((t) => t.done);
        break;
    }
    // Stable order: newest first by createdAt desc (then id for tie-break)
    final list = out.toList()
      ..sort((a, b) {
        final cmp = b.createdAt.compareTo(a.createdAt);
        return cmp != 0 ? cmp : b.id.compareTo(a.id);
      });
    return list;
  }
}
