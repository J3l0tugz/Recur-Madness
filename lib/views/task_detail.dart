import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_crud_example/models/task_model.dart';
import 'package:intl/intl.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';

/// Utility function to get the next recurrence date (date-only) based on the task's dueDate and recurrence type.
DateTime getNextRecurrenceDate(Task task) {
  // Extract only the date part from the task's dueDate.
  DateTime dueDate =
      DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
  // If the task does not recur, return the dueDate.
  if (task.recurrence == 1) return dueDate;

  // Get today's date (date-only).
  DateTime today = DateTime.now();
  DateTime todayDate = DateTime(today.year, today.month, today.day);
  DateTime nextDate = dueDate;

  // Keep adding the recurrence interval until nextDate is today or later.
  while (nextDate.isBefore(todayDate)) {
    switch (task.recurrence) {
      case 2: // Daily
        nextDate = nextDate.add(Duration(days: 1));
        break;
      case 3: // Weekly
        nextDate = nextDate.add(Duration(days: 7));
        break;
      case 4: // Monthly
        nextDate = DateTime(nextDate.year, nextDate.month + 1, nextDate.day);
        break;
      default:
        break;
    }
  }
  return nextDate;
}

/// Helper function: Checks if a given date is the same as today's date (ignoring time).
bool _isSameDate(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

String formatDate(DateTime date) {
  return DateFormat('MM/dd/yyyy').format(date);
}

class TaskDetailPage extends StatefulWidget {
  final Task task;

  const TaskDetailPage({super.key, required this.task});

  @override
  // ignore: library_private_types_in_public_api
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late Task _currentTask;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _dueDateController;
  late int _selectedCategory;
  late int _selectedStatus;
  late int _selectedRecurrence;

  final Map<int, IconData> categoryIcons = {
    1: Icons.work,
    2: Icons.home,
    3: Icons.sports,
    4: Icons.shopping_cart,
    5: Icons.travel_explore,
  };

  final Map<int, String> categoryMap = {
    1: "Work",
    2: "Home",
    3: "Sports",
    4: "Shopping",
    5: "Travel",
  };

  final Map<int, String> statusMap = {
    1: "Active",
    2: "Pending",
    3: "Completed",
  };

  final Map<int, String> recurrenceMap = {
    1: "None",
    2: "Daily",
    3: "Weekly",
    4: "Monthly",
  };

  @override
  void initState() {
    super.initState();
    _currentTask = widget.task;
    _nameController = TextEditingController(text: _currentTask.name);
    _descriptionController =
        TextEditingController(text: _currentTask.description);
    _dueDateController =
        TextEditingController(text: formatDate(_currentTask.dueDate));
    _selectedCategory = _currentTask.category;
    _selectedStatus = _currentTask.status;
    _selectedRecurrence = _currentTask.recurrence;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  /// Returns a combined status string.
  /// - For active/pending tasks, returns the status along with "• Due now" if either the original due date
  ///   or (for recurring tasks) the next recurrence date is today.
  /// - For completed tasks:
  ///   - If non-recurring, returns "Completed" (or "Due now" if due today).
  ///   - If recurring, returns "Completed • Next in X days" (or "Completed • Due now" if the next recurrence is today).
  String _getStatusText(Task task) {
    final now = DateTime.now();
    final dueDate = task.dueDate;

    if (task.status == 3) {
      // Completed tasks.
      if (task.recurrence != 1) {
        // For recurring completed tasks, show countdown for next occurrence.
        final nextRecurrenceDate = getNextRecurrenceDate(task);
        final nextDiff = nextRecurrenceDate.difference(now);
        String countdownText = nextDiff.inDays == 0
            ? "Due now"
            : "Next in ${nextDiff.inDays} days";
        return "Completed • $countdownText";
      } else {
        // For non-recurring completed tasks.
        if (_isSameDate(dueDate)) {
          return "Due now";
        }
        return "Completed";
      }
    } else if (task.status == 1 || task.status == 2) {
      // For active or pending tasks.
      String baseStatus = statusMap[task.status]!;
      // Check if the original due date is today.
      bool dueNow = _isSameDate(dueDate);
      // If not, and if the task recurs, check if the next recurrence is today.
      if (!dueNow && task.recurrence != 1) {
        final nextRecurrenceDate = getNextRecurrenceDate(task);
        dueNow = _isSameDate(nextRecurrenceDate);
      }
      if (dueNow) {
        return "$baseStatus • Due now";
      }
      return baseStatus;
    }
    return statusMap[task.status]!;
  }

  Color _getStatusColor(int status) {
    switch (status) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskLoaded) {
          final updatedTask = state.tasks.firstWhere(
              (task) => task.id == _currentTask.id,
              orElse: () => _currentTask);
          setState(() {
            _currentTask = updatedTask;
            _nameController.text = updatedTask.name;
            _descriptionController.text = updatedTask.description;
            _dueDateController.text = formatDate(updatedTask.dueDate);
            _selectedCategory = updatedTask.category;
            _selectedStatus = updatedTask.status;
            _selectedRecurrence = updatedTask.recurrence;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0x002c3e50),
          toolbarHeight: 80,
          leadingWidth: 90,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 22,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Tasks',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
              onPressed: () {
                _showEditTaskDialog(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Theme.of(context).primaryColor),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Delete Task",
                          style: TextStyle(fontSize: 18)),
                      content: const Text(
                          "Are you sure you want to delete this task?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancel",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).primaryColor)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.red,
                            backgroundColor:
                                const Color.fromARGB(255, 65, 22, 18),
                          ),
                          onPressed: () {
                            context
                                .read<TaskBloc>()
                                .add(DeleteTask(_currentTask.id));
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: const Text("Delete",
                              style: TextStyle(fontSize: 14)),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
        backgroundColor: const Color(0xFF000000),
        body: Container(
          color: const Color(0xFF000000),
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _currentTask.name,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                _currentTask.description,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(categoryIcons[_currentTask.category], size: 18),
                      const SizedBox(width: 8),
                      Text(
                        categoryMap[_currentTask.category]!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        formatDate(_currentTask.dueDate),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: _getStatusColor(_currentTask.status),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          _getStatusText(_currentTask),
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Edit Task", style: TextStyle(fontSize: 20)),
              content: SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: "Name"),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _descriptionController,
                        decoration:
                            const InputDecoration(labelText: "Description"),
                        style: const TextStyle(fontSize: 16),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _selectedCategory,
                        items: categoryMap.entries.map((entry) {
                          return DropdownMenuItem<int>(
                            value: entry.key,
                            child: Text(entry.value,
                                style: const TextStyle(fontSize: 16)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                        decoration:
                            const InputDecoration(labelText: "Category"),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _selectedStatus,
                        items: statusMap.entries.map((entry) {
                          return DropdownMenuItem<int>(
                            value: entry.key,
                            child: Text(entry.value,
                                style: const TextStyle(fontSize: 16)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                        decoration: const InputDecoration(labelText: "Status"),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _selectedRecurrence,
                        items: recurrenceMap.entries.map((entry) {
                          return DropdownMenuItem<int>(
                            value: entry.key,
                            child: Text(entry.value,
                                style: const TextStyle(fontSize: 16)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRecurrence = value!;
                          });
                        },
                        decoration:
                            const InputDecoration(labelText: "Recurrence"),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _dueDateController,
                        decoration: InputDecoration(
                          labelText: "Due Date (MM/DD/YYYY)",
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  _dueDateController.text =
                                      formatDate(pickedDate);
                                });
                              }
                            },
                          ),
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel",
                      style: TextStyle(
                          fontSize: 14, color: Theme.of(context).primaryColor)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final updatedTask = Task(
                      id: _currentTask.id,
                      name: _nameController.text,
                      description: _descriptionController.text,
                      category: _selectedCategory,
                      status: _selectedStatus,
                      dueDate: DateTime.parse(DateFormat('MM/dd/yyyy')
                          .parse(_dueDateController.text)
                          .toIso8601String()),
                      recurrence: _selectedRecurrence,
                    );
                    context.read<TaskBloc>().add(UpdateTask(
                          id: updatedTask.id,
                          name: updatedTask.name,
                          description: updatedTask.description,
                          category: updatedTask.category,
                          status: updatedTask.status,
                          dueDate: updatedTask.dueDate,
                          recurrence: updatedTask.recurrence,
                        ));
                    Navigator.pop(context);
                  },
                  child: const Text("Save", style: TextStyle(fontSize: 14)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
