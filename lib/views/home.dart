import 'package:bloc_crud_example/bloc/task_event.dart';
import 'package:bloc_crud_example/models/task_model.dart';
import 'package:bloc_crud_example/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_state.dart';
import 'task_list.dart';
import 'task_detail.dart';
import 'dart:ui';

/// Utility function to get the next recurrence date based on the task's dueDate and recurrence type.
DateTime getNextRecurrenceDate(Task task) {
  DateTime nextDate = task.dueDate;

  do {
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
        return nextDate; // Non-recurring
    }
  } while (nextDate.isBefore(DateTime.now()));

  return nextDate;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0x002c3e50),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recur',
                  style: TextStyle(fontWeight: FontWeight.w300, fontSize: 24),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'M',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                      TextSpan(
                        text: 'a',
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 24,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      TextSpan(
                        text: 'dness',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 24),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Image.asset(
              'lib/assets/image/fire.png',
              height: 40,
              width: 40,
              fit: BoxFit.contain,
            ),
          ],
        ),
        toolbarHeight: 80,
        centerTitle: false,
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const LoadingWidget();
          }
          if (state is TaskError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded,
                      size: 50, color: Colors.orangeAccent),
                  SizedBox(height: 10),
                  Text(
                    "Oops! Something went wrong 🤕",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
          }

          if (state is TaskLoaded) {
            final activeTasks =
                state.tasks.where((task) => task.status == 1).length;
            final pendingTasks =
                state.tasks.where((task) => task.status == 2).length;
            final completedTasks =
                state.tasks.where((task) => task.status == 3).length;
            final recurringTasks =
                state.tasks.where((task) => task.recurrence != 1).toList();

            // Sort recurring tasks by next recurrence date.
            recurringTasks.sort((a, b) =>
                getNextRecurrenceDate(a).compareTo(getNextRecurrenceDate(b)));

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDashboardItem("Active", activeTasks, 1,
                            Icons.lightbulb, Colors.deepPurpleAccent),
                        SizedBox(height: 2),
                        _buildDashboardItem(
                            "Pending",
                            pendingTasks,
                            2,
                            Icons.timer,
                            Colors.orangeAccent),
                        SizedBox(height: 2),
                        _buildDashboardItem("Completed", completedTasks, 3,
                            Icons.check_circle, Colors.green),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverHeaderDelegate(
                    minHeight: 60,
                    maxHeight: 60,
                    child: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Text(
                        "Recurring Tasks",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),

                // Recurring tasks list or an empty view.
                recurringTasks.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'lib/assets/gif/coming_soon.gif',
                                  height: 250,
                                  width: 250,
                                  fit: BoxFit.contain,
                                ),
                                const Text(
                                  "No recurring tasks yet! 🔁",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                const Text(
                                  "Create recurring tasks for better organization! 🎯",
                                  softWrap: true,
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final task = recurringTasks[index];
                            final nextRecurrenceDate =
                                getNextRecurrenceDate(task);
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18.0, vertical: 1.0),
                              child: HoverableTaskCard(
                                task: task,
                                nextRecurrenceDate: nextRecurrenceDate,
                              ),
                            );
                          },
                          childCount: recurringTasks.length,
                        ),
                      )
              ],
            );
          }
          return Center(child: Text("Press a button to load tasks"));
        },
      ),
    );
  }

  Widget _buildDashboardItem(
      String title, int count, int status, IconData icon, Color iconColor) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        contentPadding: EdgeInsets.all(14.0),
        leading: Icon(icon, color: iconColor, size: 28),
        title: Text(
          title,
          style: TextStyle(fontSize: 14, color: Color(0xf7f7f7f7)),
        ),
        trailing: Text(
          count.toString(),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: Duration(milliseconds: 300),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  TaskList(selectedStatus: status),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(position: offsetAnimation, child: child);
              },
            ),
          );
        },
      ),
    );
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color:
              Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.3),
          child: child,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class HoverableTaskCard extends StatefulWidget {
  final Task task;
  final DateTime nextRecurrenceDate;

  const HoverableTaskCard({
    super.key,
    required this.task,
    required this.nextRecurrenceDate,
  });

  @override
  // ignore: library_private_types_in_public_api
  _HoverableTaskCardState createState() => _HoverableTaskCardState();
}

class _HoverableTaskCardState extends State<HoverableTaskCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  String _getCountdownText(Task task) {
    final now = DateTime.now();
    final dueDate = task.dueDate;
    final difference = dueDate.difference(now);

    // Completed tasks logic.
    if (task.status == 3) {
      if (task.recurrence != 1) {
        // For recurring tasks, show "Completed" with next occurrence countdown.
        final nextRecurrenceDate = getNextRecurrenceDate(task);
        final nextDiff = nextRecurrenceDate.difference(now);
        String countdownText = nextDiff.inDays == 0
            ? "Due now"
            : "Next in ${nextDiff.inDays} days";
        return "Completed • $countdownText";
      } else {
        // For non-recurring completed tasks.
        if (!difference.isNegative && difference.inDays == 0) {
          return "Due now";
        } else {
          return "Completed";
        }
      }
    }

    // Active or pending tasks.
    if (!difference.isNegative) {
      if (difference.inDays == 0) {
        return "Due now";
      }
      return "${difference.inDays} days left";
    } else {
      // Task is overdue.
      final overdueDuration = now.difference(dueDate);

      // For non-recurring tasks.
      if (task.recurrence == 1) {
        if (overdueDuration.inDays == 0) {
          return "Due now";
        }
        return "${overdueDuration.inDays} days overdue";
      }

      // For recurring tasks, show countdown to next recurrence.
      final nextRecurrenceDate = getNextRecurrenceDate(task);
      final nextDiff = nextRecurrenceDate.difference(now);

      if (nextDiff.inDays == 0) {
        return "Due now";
      } else {
        return "Next in ${nextDiff.inDays} days";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: Duration(milliseconds: 300),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  TaskDetailPage(task: widget.task),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);

                return SlideTransition(position: offsetAnimation, child: child);
              },
            ),
          );
        },
        child: Card(
          margin: EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 10.0, 10.0),
            title: Text(
              widget.task.name,
              style: TextStyle(fontSize: 14),
            ),
            subtitle: Text(
              _getCountdownText(widget.task),
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            trailing: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              transform: Matrix4.translationValues(
                _isHovered || _isPressed ? 10.0 : 0.0,
                0.0,
                0.0,
              ),
              child: Icon(Icons.arrow_forward,
                  size: 24, color: Theme.of(context).primaryColor),
            ),
          ),
        ),
      ),
    );
  }
}
