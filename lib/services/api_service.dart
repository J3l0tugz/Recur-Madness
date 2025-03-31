import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/task_model.dart';

class ApiService {
  final String baseUrl = "https://j3l0tugz.github.io/api_task/tasks.json";
  List<Task> _tasks = [];

  Future<List<Task>> getTasks() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['tasks'];
      _tasks = data.map((json) => Task.fromJson(json)).toList();
      return _tasks;
    } else {
      throw Exception("Failed to load tasks");
    }
  }

  Future<Task> createTask(String name, String description, int category,
      int status, DateTime dueDate, int recurrence) async {
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch,
      name: name,
      description: description,
      category: category,
      status: status,
      dueDate: dueDate, 
      recurrence: recurrence,
    );
    _tasks.add(newTask);
    return Future.value(newTask);
  }

  Future<Task> updateTask(int id, String name, String description, int category,
      int status, DateTime dueDate, int recurrence) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == id);
    if (taskIndex == -1) {
      throw Exception("Task not found");
    }
    final updatedTask = Task(
      id: id,
      name: name,
      description: description,
      category: category,
      status: status,
      dueDate: dueDate,
      recurrence: recurrence,
    );
    _tasks[taskIndex] = updatedTask;
    return Future.value(updatedTask);
  }

  Future<void> deleteTask(int id) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == id);
    if (taskIndex == -1) {
      throw Exception("Task not found");
    }
    _tasks.removeAt(taskIndex);
    return Future.value();
  }
}
