import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'task_model.dart';
import 'task_provider.dart';
import 'task_list.dart';
import 'progress_ring.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PocketTasksApp());
}

class PocketTasksApp extends StatelessWidget {
  const PocketTasksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider()..load(),
      child: MaterialApp(
        title: 'PocketTasks',
        themeMode: ThemeMode.system,
        theme: ThemeData(
          colorSchemeSeed: Colors.teal,
          brightness: Brightness.light,
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorSchemeSeed: Colors.teal,
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        home: const PocketTasksPage(),
      ),
    );
  }
}

class PocketTasksPage extends StatefulWidget {
  const PocketTasksPage({super.key});

  @override
  State<PocketTasksPage> createState() => _PocketTasksPageState();
}

class _PocketTasksPageState extends State<PocketTasksPage> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      context.read<TaskProvider>().setQuery(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _addTask() {
    final title = _controller.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Title cannot be empty');
      _focus.requestFocus();
      return;
    }
    setState(() => _error = null);
    final id = const Uuid().v4();
    context.read<TaskProvider>().addTask(Task(
      id: id,
      title: title,
      done: false,
      createdAt: DateTime.now(),
    ));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E005C), // deep violet
            Color(0xFF6A1B9A), // purple accent
            Color(0xFF8E24AA), // lighter purple
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // show gradient
        appBar: AppBar(
          title: const Text('PocketTasks'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Consumer<TaskProvider>(
              builder: (_, provider, __) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: ProgressRing(
                    total: provider.totalCount,
                    done: provider.doneCount,
                    size: 40,
                    strokeWidth: 5,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focus,
                        decoration: InputDecoration(
                          labelText: 'Add or search tasks',
                          hintText: 'e.g. Buy milk, read book...',
                          errorText: _error,
                          border: const OutlineInputBorder(),
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                        ),
                        style: const TextStyle(color: Colors.white),
                        onSubmitted: (_) => _addTask(),
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: 'Add task',
                      child: ElevatedButton.icon(
                        onPressed: _addTask,
                        icon: const Icon(Icons.add),
                        label: const Text('Add'),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Consumer<TaskProvider>(
                  builder: (context, provider, _) {
                    return Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('All', style: TextStyle(color: Colors.white)),
                          selected: provider.filter == TaskFilter.all,
                          selectedColor: Colors.teal,
                          checkmarkColor: Colors.white,
                          onSelected: (_) => provider.setFilter(TaskFilter.all),
                        ),
                        FilterChip(
                          label: const Text('Active', style: TextStyle(color: Colors.white)),
                          selected: provider.filter == TaskFilter.active,
                          selectedColor: Colors.teal,
                          checkmarkColor: Colors.white,
                          onSelected: (_) => provider.setFilter(TaskFilter.active),
                        ),
                        FilterChip(
                          label: const Text('Done', style: TextStyle(color: Colors.white)),
                          selected: provider.filter == TaskFilter.done,
                          selectedColor: Colors.teal,
                          checkmarkColor: Colors.white,
                          onSelected: (_) => provider.setFilter(TaskFilter.done),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Consumer<TaskProvider>(
                  builder: (context, provider, _) {
                    if (provider.visibleTasks.isEmpty) {
                      return const _EmptyState();
                    }
                    return TaskList();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined,
              size: 56, color: theme.colorScheme.onSurface.withOpacity(0.6)),
          const SizedBox(height: 8),
          Text('No tasks yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Add your first task to get started',
              style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
