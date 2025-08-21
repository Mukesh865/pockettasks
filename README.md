# PocketTasks

A simple, cross-platform task management application built with Flutter.

![PocketTasks Screenshot 1](pockettask1.jpg)
![PocketTasks Screenshot 2](pockettask2.jpg)
![PocketTasks Screenshot 3](pockettask3.jpg)

## Features

- **Task Management**: Add, complete, and delete tasks easily.
- **State Persistence**: Tasks are saved locally on the device using `shared_preferences`, so they persist between app launches.
- **Filtering**: View all tasks, only active tasks, or only completed tasks using filter chips.
- **Searching**: Search for tasks by title with a debounced search bar to improve performance.
- **Undo Functionality**: The app provides a snack bar with an "Undo" option for toggling task completion and deleting tasks.
- **Progress Indicator**: A progress ring in the app bar shows the number of completed tasks out of the total.
- **Theme Toggling**: Switch between light and dark modes with a dedicated button in the app bar.
- **Responsive UI**: The UI is designed to be adaptive and visually pleasing on different screen sizes.
- **Glassmorphism Effect**: The task list items feature a subtle blur effect on their background, giving them a modern "glassmorphism" look.
- **Cross-Platform**: Developed with Flutter, PocketTasks is designed to run on multiple platforms, including Android, iOS, macOS, Linux, and Windows.

## Technical Details

The application is built using the Flutter framework and Dart language. Key packages used include:

- `provider`: For state management, specifically `TaskProvider` and `ThemeProvider`.
- `shared_preferences`: For local data storage to persist tasks.
- `uuid`: To generate unique identifiers for each task.

The core logic is handled in the `TaskProvider` class, which uses `ChangeNotifier` to manage the state of the task list, filters, and search queries. The app's theme is also managed by a `ThemeProvider`. The `TaskList` widget dynamically displays tasks based on the current filter and search query.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the [online documentation](https://docs.flutter.dev/), which offers tutorials, samples, guidance on mobile development, and a full API reference.
