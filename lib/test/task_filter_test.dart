import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../task_model.dart';
import '../task_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TaskProvider Filtering and Searching', () {
    setUp(() {
      // Mock SharedPreferences to prevent runtime errors in tests
      SharedPreferences.setMockInitialValues({});
    });

    test('filteredTasks returns all tasks when filter is "All"', () {
      final provider = TaskProvider();
      provider.addTask(Task(title: 'Task 1'));
      provider.addTask(Task(title: 'Task 2', isCompleted: true));
      provider.setFilter(TaskFilter.all);

      expect(provider.filteredTasks.length, 2);
    });

    test('filteredTasks returns only active tasks when filter is "Active"', () {
      final provider = TaskProvider();
      provider.addTask(Task(title: 'Task 1'));
      provider.addTask(Task(title: 'Task 2', isCompleted: true));
      provider.setFilter(TaskFilter.active);

      expect(provider.filteredTasks.length, 1);
      expect(provider.filteredTasks.first.title, 'Task 1');
    });

    test('filteredTasks returns only done tasks when filter is "Done"', () {
      final provider = TaskProvider();
      provider.addTask(Task(title: 'Task 1'));
      provider.addTask(Task(title: 'Task 2', isCompleted: true));
      provider.setFilter(TaskFilter.done);

      expect(provider.filteredTasks.length, 1);
      expect(provider.filteredTasks.first.title, 'Task 2');
    });

    test('search query filters tasks correctly', () {
      final provider = TaskProvider();
      provider.addTask(Task(title: 'Buy groceries'));
      provider.addTask(Task(title: 'Walk the dog'));
      provider.addTask(Task(title: 'Call Alice'));

      provider.setSearchQuery('walk');

      expect(provider.filteredTasks.length, 1);
      expect(provider.filteredTasks.first.title, 'Walk the dog');
    });

    test('search query works in combination with "Active" filter', () {
      final provider = TaskProvider();
      provider.addTask(Task(title: 'Buy groceries')); // Active
      provider.addTask(Task(title: 'Walk the dog', isCompleted: true)); // Done
      provider.addTask(Task(title: 'Call Alice')); // Active

      provider.setFilter(TaskFilter.active);
      provider.setSearchQuery('al');

      expect(provider.filteredTasks.length, 1);
      expect(provider.filteredTasks.first.title, 'Call Alice');
    });
  });
}