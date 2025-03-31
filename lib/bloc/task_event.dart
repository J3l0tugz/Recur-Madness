abstract class TaskEvent {}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final String name;
  final String description;
  final int category;
  final int status;
  final DateTime dueDate;
  final int recurrence;

  AddTask({
    required this.name,
    required this.description,
    required this.category,
    required this.status,
    required this.dueDate,
    required this.recurrence,
  });
}

class UpdateTask extends TaskEvent {
  final int id;
  final String name;
  final String description;
  final int category;
  final int status;
  final DateTime dueDate;
  final int recurrence;

  UpdateTask({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.status,
    required this.dueDate,
    required this.recurrence,
  });
}

class DeleteTask extends TaskEvent {
  final int id;

  DeleteTask(this.id);
}
