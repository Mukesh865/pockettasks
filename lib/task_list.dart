import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_provider.dart';
import 'task_model.dart';

class TaskList extends StatelessWidget {
  const TaskList({super.key});

  void _showSnackBar(BuildContext context, String message, {VoidCallback? onUndo}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: onUndo != null
            ? SnackBarAction(
          label: 'Undo',
          onPressed: onUndo,
        )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = taskProvider.filteredTasks;
        if (tasks.isEmpty && taskProvider.tasks.isNotEmpty) {
          return const Center(child: Text('No tasks match the current filter or search.'));
        } else if (tasks.isEmpty) {
          return const Center(child: Text('No tasks yet! Add one above.'));
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Dismissible(
              key: Key(task.id),
              direction: DismissDirection.horizontal,
              onDismissed: (direction) {
                taskProvider.removeTask(task);
                _showSnackBar(
                  context,
                  'Task "${task.title}" deleted.',
                  onUndo: () {
                    taskProvider.addTask(task); // Re-add the task on undo
                  },
                );
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: Card(
                elevation: 1,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: CheckboxListTile(
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      fontStyle: task.isCompleted ? FontStyle.italic : FontStyle.normal,
                      color: task.isCompleted
                          ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                          : null,
                    ),
                  ),
                  value: task.isCompleted,
                  onChanged: (_) {
                    taskProvider.toggleTaskCompletion(task);
                    final message = task.isCompleted
                        ? 'Task "${task.title}" marked as complete.'
                        : 'Task "${task.title}" marked as active.';
                    _showSnackBar(context, message);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}