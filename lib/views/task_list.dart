import 'package:bloc_crud_example/bloc/task_event.dart';
import 'package:bloc_crud_example/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_state.dart';
import '../models/task_model.dart';
import 'task_detail.dart';

class TaskList extends StatefulWidget {
  final int selectedStatus;

  const TaskList({super.key, required this.selectedStatus});

  @override
  // ignore: library_private_types_in_public_api
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  int _filterStatus = 0;

  final Map<int, String> categoryMap = {
    1: "Work",
    2: "Home",
    3: "Sports",
    4: "Shopping",
    5: "Travel",
  };

  final Map<int, IconData> categoryIcons = {
    1: Icons.work,
    2: Icons.home,
    3: Icons.sports,
    4: Icons.shopping_cart,
    5: Icons.travel_explore,
  };

  final Map<int, String> statusMap = {
    1: "Active",
    2: "Pending",
    3: "Completed",
  };

  final Map<int, Color> statusColors = {
    1: Colors.deepPurpleAccent,
    2: Colors.orange,
    3: Colors.green,
  };

  final Map<int, IconData> statusIcons = {
    1: Icons.lightbulb,
    2: Icons.timer,
    3: Icons.check_circle,
  };

  String getStatusTitle() {
    switch (widget.selectedStatus) {
      case 1:
        return 'Active Tasks';
      case 2:
        return 'Pending Tasks';
      case 3:
        return 'Completed Tasks';
      default:
        return 'Tasks';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.selectedStatus > 0 ? Colors.black : null,
      appBar: AppBar(
        backgroundColor: Color(0x002c3e50),
        toolbarHeight: 80,
        leadingWidth: 100,
        leading: widget.selectedStatus != 0
            ? InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Theme.of(context).primaryColor,
                        size: 22,
                      ),
                    ),
                    Text(
                      'Home',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              )
            : null,
        centerTitle: widget.selectedStatus > 0 ? true : false,
        title: widget.selectedStatus >= 1 && widget.selectedStatus <= 3
            ? Text(
                getStatusTitle(),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )
            : Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: const Text(
                  'Tasks',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
        actions: widget.selectedStatus == 0
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: PopupMenuButton<int>(
                    icon: Icon(Icons.more_horiz,
                        color: Theme.of(context).primaryColor),
                    onSelected: (int selectedValue) {
                      setState(() {
                        _filterStatus = selectedValue;
                      });
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 0, child: Text("All")),
                      PopupMenuItem(value: 1, child: Text("Active")),
                      PopupMenuItem(value: 2, child: Text("Pending")),
                      PopupMenuItem(value: 3, child: Text("Completed")),
                    ],
                  ),
                ),
              ]
            : [],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                if (state is TaskLoading) {
                  return const LoadingWidget();
                } else if (state is TaskError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            size: 50, color: Colors.orangeAccent),
                        SizedBox(height: 10),
                        Text(
                          "Oops! Something went wrong 🤕",
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            context.read<TaskBloc>().add(LoadTasks());
                          },
                          icon: Icon(Icons.refresh),
                          label: Text(
                            "Try Again",
                            style: TextStyle(fontSize: 12, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is TaskLoaded) {
                  List<Task> tasks =
                      (_filterStatus == 0 && widget.selectedStatus == 0)
                          ? state.tasks
                          : state.tasks
                              .where((task) =>
                                  task.status ==
                                  (_filterStatus == 0
                                      ? widget.selectedStatus
                                      : _filterStatus))
                              .toList();
                  // Sort tasks based on their dueDate (earlier first).
                  tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));

                  if (tasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'lib/assets/gif/no_tasks_found.gif',
                            height: 300,
                            width: 300,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "You're all caught up! 🎉",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Time to create more tasks! 🚀",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        final formattedDate =
                            DateFormat('MM/dd/yy').format(task.dueDate);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 2.0),
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    transitionDuration:
                                        const Duration(milliseconds: 300),
                                    pageBuilder: (context, animation,
                                            secondaryAnimation) =>
                                        TaskDetailPage(task: task),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) {
                                      const begin = Offset(1.0, 0.0);
                                      const end = Offset.zero;
                                      const curve = Curves.easeInOut;
                                      var tween = Tween(begin: begin, end: end)
                                          .chain(CurveTween(curve: curve));
                                      var offsetAnimation =
                                          animation.drive(tween);
                                      return SlideTransition(
                                          position: offsetAnimation,
                                          child: child);
                                    },
                                  ),
                                );
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(22, 20, 20, 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            task.name,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Icon(
                                          statusIcons[task.status],
                                          color: statusColors[task.status],
                                          size: 24,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          formattedDate,
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                        Expanded(
                                          child: Text(
                                            "\t\t${task.description}",
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: false,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return const Center(
                      child: Text("Press a button to load tasks"));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
