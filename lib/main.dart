import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'task_model.dart';
import 'task_provider.dart';
import 'task_list.dart';
import 'progress_ring.dart';

void main() {
  runApp(const PocketTasksApp());
}

class PocketTasksApp extends StatelessWidget {
  const PocketTasksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: MaterialApp(
        title: 'PocketTasks',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const TaskManagerScreen(),
      ),
    );
  }
}

class TaskManagerScreen extends StatefulWidget {
  const TaskManagerScreen({super.key});

  @override
  State<TaskManagerScreen> createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _taskFocusNode = FocusNode();
  String? _taskErrorText;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    context.read<TaskProvider>().loadTasks();
  }

  @override
  void dispose() {
    _taskController.dispose();
    _searchController.dispose();
    _taskFocusNode.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      context.read<TaskProvider>().setSearchQuery(_searchController.text);
    });
  }

  void _addTask() {
    final title = _taskController.text.trim();
    if (title.isEmpty) {
      setState(() {
        _taskErrorText = 'Task title cannot be empty';
      });
      _taskFocusNode.requestFocus();
    } else {
      setState(() {
        _taskErrorText = null;
      });
      context.read<TaskProvider>().addTask(Task(title: title));
      _taskController.clear();
      _taskFocusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PocketTasks'),
        centerTitle: false,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: ProgressRing(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    focusNode: _taskFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Enter task title...',
                      labelText: 'New Task',
                      errorText: _taskErrorText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.add),
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTask,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: taskProvider.currentFilter == TaskFilter.all,
                        onSelected: (_) => taskProvider.setFilter(TaskFilter.all),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Active'),
                        selected: taskProvider.currentFilter == TaskFilter.active,
                        onSelected: (_) => taskProvider.setFilter(TaskFilter.active),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Done'),
                        selected: taskProvider.currentFilter == TaskFilter.done,
                        onSelected: (_) => taskProvider.setFilter(TaskFilter.done),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const Expanded(
              child: TaskList(),
            ),
          ],
        ),
      ),
    );
  }
}