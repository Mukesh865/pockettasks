import 'dart:async';
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

// A simple provider to manage the app's ThemeMode
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default to system theme

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Notify listeners to rebuild the UI with the new theme
  }
}

class PocketTasksApp extends StatelessWidget {
  const PocketTasksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide the ThemeProvider to manage theme state
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // Provide the TaskProvider to manage task data
        ChangeNotifierProvider(create: (_) => TaskProvider()..load()),
      ],
      // Consume the ThemeProvider to rebuild MaterialApp when theme changes
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'PocketTasks',
            themeMode: themeProvider.themeMode, // Use the theme mode from ThemeProvider
            theme: ThemeData(
              // Light theme configuration
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple, // A consistent seed color
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: Colors.white, // Clean white background
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white, // White AppBar
                elevation: 0.5, // Subtle shadow for AppBar
                iconTheme: IconThemeData(color: Colors.black87), // Dark icons
                titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold), // Dark title text
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.grey.shade100, // Light grey fill for text fields
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none, // No border line, relying on fill color
                ),
                hintStyle: TextStyle(color: Colors.grey.shade600), // Slightly darker hint text
                labelStyle: const TextStyle(color: Colors.black), // Dark label text
              ),
              chipTheme: const ChipThemeData(
                selectedColor: Colors.deepPurple, // Purple for selected chip
                backgroundColor: Colors.white, // White background for unselected chips
                labelStyle: TextStyle(color: Colors.deepPurple), // Purple label for selected, default for unselected
                checkmarkColor: Colors.white, // White checkmark on selected chip
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple, // Purple buttons
                  foregroundColor: Colors.white, // White text on buttons
                ),
              ),
            ),
            darkTheme: ThemeData(
              // Dark theme configuration (can be further customized)
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
            ),
            home: const PocketTasksPage(),
          );
        },
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
  Timer? _searchDebounce; // Timer for debouncing search input

  @override
  void initState() {
    super.initState();
    // Listen for text changes in the search controller to implement debouncing
    _controller.addListener(_onSearchChanged);
    // Load tasks when the page initializes
    context.read<TaskProvider>().load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    _searchDebounce?.cancel(); // Cancel any active debounce timer
    super.dispose();
  }

  // Handle search input changes with a debounce
  void _onSearchChanged() {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel(); // Cancel previous timer
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      context.read<TaskProvider>().setQuery(_controller.text); // Update search query after delay
    });
  }

  void _addTask() {
    final title = _controller.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Title cannot be empty'); // Show error for empty title
      _focus.requestFocus(); // Keep focus on the text field
      return;
    }
    setState(() => _error = null); // Clear error if title is valid
    final id = const Uuid().v4(); // Generate a unique ID for the task
    context.read<TaskProvider>().addTask(Task(
      id: id,
      title: title,
      done: false,
      createdAt: DateTime.now(),
    ));
    _controller.clear(); // Clear text field after adding task
    _focus.unfocus(); // Remove focus from text field
  }

  @override
  Widget build(BuildContext context) {
    // Adaptive gradient that matches light/dark mode
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final List<Color> gradientColors = isDark
        ? const [
            Color(0xFF2E005C), // deep violet
            Color(0xFF6A1B9A), // purple accent
            Color(0xFF8E24AA), // lighter purple
          ]
        : const [
            Color(0xFFEDE7F6), // light lavender
            Color(0xFFD1C4E9), // soft purple
            Color(0xFFB39DDB), // medium purple
          ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('PocketTasks'),
          centerTitle: false,
          actions: [
          // Progress Ring showing task completion
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
          // Theme toggle button
          IconButton(
            icon: Icon(
              // Change icon based on current theme mode
              Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark
                  ? Icons.light_mode // Show light mode icon in dark theme
                  : Icons.dark_mode, // Show dark mode icon in light theme
            ),
            onPressed: () {
              // Toggle theme mode when button is pressed
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
          const SizedBox(width: 8), // Small spacing after the icon button
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
                        labelText: 'Add task or Search',
                        hintText: 'e.g. Buy milk, read book...',
                        errorText: _error, // Display inline error message
                      ),
                      onSubmitted: (_) => _addTask(), // Add task on pressing done/enter
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
                    spacing: 8, // Spacing between filter chips
                    children: [
                      Builder(builder: (context) {
                        final colorScheme = Theme.of(context).colorScheme;
                        final selected = provider.filter == TaskFilter.all;
                        return FilterChip(
                          selected: selected,
                          selectedColor: colorScheme.primary,
                          checkmarkColor: colorScheme.onPrimary,
                          label: Text(
                            'All',
                            style: TextStyle(
                              color: selected
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                            ),
                          ),
                          onSelected: (_) => provider.setFilter(TaskFilter.all),
                        );
                      }),
                      Builder(builder: (context) {
                        final colorScheme = Theme.of(context).colorScheme;
                        final selected = provider.filter == TaskFilter.active;
                        return FilterChip(
                          selected: selected,
                          selectedColor: colorScheme.primary,
                          checkmarkColor: colorScheme.onPrimary,
                          label: Text(
                            'Active',
                            style: TextStyle(
                              color: selected
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                            ),
                          ),
                          onSelected: (_) => provider.setFilter(TaskFilter.active),
                        );
                      }),
                      Builder(builder: (context) {
                        final colorScheme = Theme.of(context).colorScheme;
                        final selected = provider.filter == TaskFilter.done;
                        return FilterChip(
                          selected: selected,
                          selectedColor: colorScheme.primary,
                          checkmarkColor: colorScheme.onPrimary,
                          label: Text(
                            'Done',
                            style: TextStyle(
                              color: selected
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                            ),
                          ),
                          onSelected: (_) => provider.setFilter(TaskFilter.done),
                        );
                      }),
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
                    return const _EmptyState(); // Show empty state if no tasks
                  }
                  return const TaskList(); // Display the list of tasks
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

// Widget to display when there are no tasks
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