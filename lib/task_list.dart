import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'task_provider.dart';
import 'task_model.dart';

class TaskList extends StatelessWidget {
  const TaskList({super.key});

  void _showSnackBar(BuildContext context, String message,
      {VoidCallback? onUndo}) {
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
        final tasks = taskProvider.visibleTasks;

        if (tasks.isEmpty && taskProvider.tasks.isNotEmpty) {
          return const Center(
              child: Text('No tasks match the current filter or search.',
                  style: TextStyle(color: Colors.white70)));
        } else if (tasks.isEmpty) {
          return const Center(
              child: Text('No tasks yet! Add one above.',
                  style: TextStyle(color: Colors.white70)));
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Dismissible(
              key: Key(task.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.redAccent,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (direction) async {
                final (deleted, position) =
                await taskProvider.deleteTask(task.id);
                if (deleted != null) {
                  _showSnackBar(
                    context,
                    'Task "${deleted.title}" deleted.',
                    onUndo: () {
                      taskProvider.undoDelete(deleted, position);
                    },
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.15), width: 1),
                ),
                child: CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.done
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      fontStyle:
                      task.done ? FontStyle.italic : FontStyle.normal,
                      color: task.done
                          ? Colors.white70
                          : Colors.white, // pop against gradient
                    ),
                  ),
                  value: task.done,
                  onChanged: (_) async {
                    final previous = await taskProvider.toggleTask(task.id);
                    final message = previous
                        ? 'Task "${task.title}" marked as active.'
                        : 'Task "${task.title}" marked as complete.';
                    _showSnackBar(
                      context,
                      message,
                      onUndo: () {
                        taskProvider.undoToggle(task.id, previous);
                      },
                    );
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
