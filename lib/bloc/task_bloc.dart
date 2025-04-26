import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/task_model.dart';
import '../db/database_helper.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  TaskBloc(DatabaseHelper databaseHelper) : super(TaskLoading()) {
    on<LoadTasks>((event, emit) async {
      try {
        final tasks = await _dbHelper.getTasks();
        emit(TaskLoaded(tasks));
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });

    on<AddTask>((event, emit) async {
      try {
        if (state is TaskLoaded) {
          final newTask = Task(
            id: 0, // SQLite will auto-generate the ID
            name: event.name,
            description: event.description,
            category: event.category,
            status: event.status,
            dueDate: event.dueDate,
            recurrence: event.recurrence,
          );

          await _dbHelper.insertTask(newTask);
          final tasks = await _dbHelper.getTasks();
          emit(TaskLoaded(tasks));
        }
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });

    on<UpdateTask>((event, emit) async {
      try {
        final updatedTask = Task(
          id: event.id,
          name: event.name,
          description: event.description,
          category: event.category,
          status: event.status,
          dueDate: event.dueDate,
          recurrence: event.recurrence,
        );

        await _dbHelper.updateTask(updatedTask);
        final tasks = await _dbHelper.getTasks();
        emit(TaskLoaded(tasks));
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });

    on<DeleteTask>((event, emit) async {
      try {
        await _dbHelper.deleteTask(event.id);
        final tasks = await _dbHelper.getTasks();
        emit(TaskLoaded(tasks));
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });
  }
}
