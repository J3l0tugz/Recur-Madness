import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final ApiService apiService;

  TaskBloc(this.apiService) : super(TaskLoading()) {
    on<LoadTasks>((event, emit) async {
      try {
        final tasks = await apiService.getTasks();
        emit(TaskLoaded(tasks));
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });

    on<AddTask>((event, emit) async {
      try {
        if (state is TaskLoaded) {
          final currentState = state as TaskLoaded;

          // Check if task with the same name already exists
          if (currentState.tasks.any((task) => task.name == event.name)) {
            return; // Simply return without emitting TaskError
          }

          final newTask = await apiService.createTask(
            event.name,
            event.description,
            event.category,
            event.status,
            event.dueDate,
            event.recurrence,
          );

          final updatedTasks = List<Task>.from(currentState.tasks)
            ..add(newTask);
          emit(TaskLoaded(updatedTasks));
        }
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });

    on<UpdateTask>((event, emit) async {
      try {
        final updatedTask = await apiService.updateTask(
          event.id,
          event.name,
          event.description,
          event.category,
          event.status,
          event.dueDate,
          event.recurrence,
        );
        final updatedTasks = (state as TaskLoaded).tasks.map((task) {
          return task.id == updatedTask.id ? updatedTask : task;
        }).toList();
        emit(TaskLoaded(updatedTasks));
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });

    on<DeleteTask>((event, emit) async {
      try {
        await apiService.deleteTask(event.id);
        final updatedTasks = (state as TaskLoaded)
            .tasks
            .where((task) => task.id != event.id)
            .toList();
        emit(TaskLoaded(updatedTasks));
      } catch (e) {
        emit(TaskError(e.toString()));
      }
    });
  }
}
