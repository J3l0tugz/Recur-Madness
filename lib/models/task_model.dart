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
    required this.recurrence
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: int.parse(json['id']),
      name: json['name'],
      description: json['description'],
      category: int.parse(json['category']),
      status: int.parse(json['status']),
      dueDate: DateTime.parse(json['dueDate']),
      recurrence: int.parse(json['recurrence'])
    );
  }
}
