class Task {
  String id;
  String title;
  bool isCompleted;

  Task({
    required this.title,
    this.isCompleted = false,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString();

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool,
    )..id = json['id'] as String;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }
}

enum TaskFilter { all, active, done }