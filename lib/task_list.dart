import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui'; // Import for ImageFilter
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
        final tasks = taskProvider.visibleTasks;
        final colorScheme = Theme.of(context).colorScheme;

        if (tasks.isEmpty && taskProvider.tasks.isNotEmpty) {
          return Center(
              child: Text(
                'No tasks match the current filter or search.',
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
              ));
        } else if (tasks.isEmpty) {
          return Center(
              child: Text(
                'No tasks yet! Add one above.',
                style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
              ));
        }

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return Dismissible(
              key: Key(task.id),
              direction: DismissDirection.endToStart, // Swipe from right to left to dismiss
              background: Container(
                color: Colors.redAccent, // Red background when swiping to delete
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white), // White delete icon
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
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ClipRRect( // ClipRRect is essential for rounded corners with BackdropFilter
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter( // Apply blur to the background
                    filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2), // Adjust sigmaX and sigmaY for blur intensity
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.1) // Subtle white tint for dark mode
                            : Colors.black.withOpacity(0.05), // Subtle black tint for light mode
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.2) // Border for glass effect
                              : Colors.black.withOpacity(0.1),
                          width: 1.0,
                        ),
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
                                ? colorScheme.onSurface.withOpacity(0.6)
                                : colorScheme.onSurface,
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
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}