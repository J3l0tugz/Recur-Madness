class Task {
  final int id;
  final String name;
  final String description;
  final int category;
  final int status;
  final DateTime dueDate;
  final int recurrence;

  Task({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.status,
    required this.dueDate,
    required this.recurrence,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as int,
      status: json['status'] as int,
      dueDate: DateTime.parse(json['dueDate'] as String),
      recurrence: json['recurrence'] as int,
    );
  }
}
