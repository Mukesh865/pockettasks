import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/task_model.dart';
import '../lib/task_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TaskProvider Filtering and Searching', () {
    setUp(() {
      // Mock SharedPreferences to prevent runtime errors in tests
      SharedPreferences.setMockInitialValues({});
    });

    Task makeTask(String id, String title,
        {bool done = false, DateTime? createdAt}) {
      return Task(
        id: id,
        title: title,
        done: done,
        createdAt: createdAt ?? DateTime.now(),
      );
    }

    test('visibleTasks returns all tasks when filter is "All"', () async {
      final provider = TaskProvider();
      await provider.addTask(makeTask('1', 'Task 1'));
      await provider.addTask(makeTask('2', 'Task 2', done: true));
      provider.setFilter(TaskFilter.all);

      expect(provider.visibleTasks.length, 2);
    });

    test('visibleTasks returns only active tasks when filter is "Active"', () async {
      final provider = TaskProvider();
      await provider.addTask(makeTask('1', 'Task 1'));
      await provider.addTask(makeTask('2', 'Task 2', done: true));
      provider.setFilter(TaskFilter.active);

      expect(provider.visibleTasks.length, 1);
      expect(provider.visibleTasks.first.title, 'Task 1');
    });

    test('visibleTasks returns only done tasks when filter is "Done"', () async {
      final provider = TaskProvider();
      await provider.addTask(makeTask('1', 'Task 1'));
      await provider.addTask(makeTask('2', 'Task 2', done: true));
      provider.setFilter(TaskFilter.done);

      expect(provider.visibleTasks.length, 1);
      expect(provider.visibleTasks.first.title, 'Task 2');
    });

    test('search query filters tasks correctly', () async {
      final provider = TaskProvider();
      await provider.addTask(makeTask('1', 'Buy groceries'));
      await provider.addTask(makeTask('2', 'Walk the dog'));
      await provider.addTask(makeTask('3', 'Call Alice'));

      provider.setQuery('walk');

      // wait a bit for debounce (300ms)
      await Future.delayed(const Duration(milliseconds: 350));

      expect(provider.visibleTasks.length, 1);
      expect(provider.visibleTasks.first.title, 'Walk the dog');
    });

    test('search query works in combination with "Active" filter', () async {
      final provider = TaskProvider();
      await provider.addTask(makeTask('1', 'Buy groceries')); // Active
      await provider.addTask(makeTask('2', 'Walk the dog', done: true)); // Done
      await provider.addTask(makeTask('3', 'Call Alice')); // Active

      provider.setFilter(TaskFilter.active);
      provider.setQuery('al');

      // wait for debounce
      await Future.delayed(const Duration(milliseconds: 350));

      expect(provider.visibleTasks.length, 1);
      expect(provider.visibleTasks.first.title, 'Call Alice');
    });
  });
}
