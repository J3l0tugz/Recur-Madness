import 'package:bloc_crud_example/bloc/task_state.dart';
import 'package:bloc_crud_example/views/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/task_bloc.dart';
import 'services/api_service.dart';
import 'bloc/task_event.dart';
import 'views/home.dart';
import 'views/task_list.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TaskBloc(ApiService())..add(LoadTasks()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Recur Madness",
        theme: ThemeData.dark().copyWith(
          hintColor: Colors.orange,
          primaryColor: Colors.orange,
          scaffoldBackgroundColor: Colors.transparent,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          textTheme: const TextTheme(
            bodyLarge:
                TextStyle(fontFamily: 'Poppins', color: Color(0xf7f7f7f7)),
            bodyMedium:
                TextStyle(fontFamily: 'Poppins', color: Color(0xf7f7f7f7)),
            bodySmall:
                TextStyle(fontFamily: 'Poppins', color: Color(0xf7f7f7f7)),
            headlineLarge: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: Color(0xf7f7f7f7)),
            headlineMedium: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: Color(0xf7f7f7f7)),
            titleLarge: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: Color(0xf7f7f7f7)),
          ),
        ),
        home: SplashScreen(),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    TaskList(selectedStatus: 0),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController dueDateController = TextEditingController();
    int selectedCategory = 1;
    int selectedStatus = 1;
    int selectedRecurrence = 1;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Add Task"),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(labelText: "Name"),
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(labelText: "Description"),
                        style: TextStyle(fontSize: 18),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: selectedCategory,
                        items: [
                          DropdownMenuItem(value: 1, child: Text("Work")),
                          DropdownMenuItem(value: 2, child: Text("Home")),
                          DropdownMenuItem(value: 3, child: Text("Sports")),
                          DropdownMenuItem(value: 4, child: Text("Shopping")),
                          DropdownMenuItem(value: 5, child: Text("Travel")),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                        decoration: InputDecoration(labelText: "Category"),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: selectedStatus,
                        items: [
                          DropdownMenuItem(value: 1, child: Text("Active")),
                          DropdownMenuItem(value: 2, child: Text("Pending")),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedStatus = value!;
                          });
                        },
                        decoration: InputDecoration(labelText: "Status"),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: selectedRecurrence,
                        items: [
                          DropdownMenuItem(value: 1, child: Text("None")),
                          DropdownMenuItem(value: 2, child: Text("Daily")),
                          DropdownMenuItem(value: 3, child: Text("Weekly")),
                          DropdownMenuItem(value: 4, child: Text("Monthly")),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedRecurrence = value!;
                          });
                        },
                        decoration: InputDecoration(labelText: "Recurrence"),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: dueDateController,
                        decoration: InputDecoration(
                          labelText: "Due Date (YYYY-MM-DD)",
                          suffixIcon: IconButton(
                            icon: Icon(Icons.calendar_today),
                            onPressed: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  dueDateController.text = pickedDate
                                      .toIso8601String()
                                      .split('T')
                                      .first;
                                });
                              }
                            },
                          ),
                        ),
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel",
                      style: TextStyle(color: Theme.of(context).primaryColor)),
                ),
                ElevatedButton(
                  onPressed: () {
                    final dueDate = DateTime.parse(dueDateController.text);
                    final taskBloc = context.read<TaskBloc>();
                    final currentState = taskBloc.state;

                    if (currentState is TaskLoaded &&
                        currentState.tasks
                            .any((task) => task.name == nameController.text)) {
                      // Check for duplicate task name
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text("Task with the same name already exists."),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                      return;
                    }

                    // Proceed with task creation if no duplicate
                    taskBloc.add(AddTask(
                      name: nameController.text,
                      description: descriptionController.text,
                      category: selectedCategory,
                      status: selectedStatus,
                      dueDate: dueDate,
                      recurrence: selectedRecurrence,
                    ));

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Task added successfully!"),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(97, 48, 43, 99), Color(0x0024243e)],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: SizedBox(
          height: 90,
          child: BottomAppBar(
            color: Color.fromARGB(61, 48, 43, 99),
            shape: CircularNotchedRectangle(),
            notchMargin: 10.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.home, size: 30),
                    color: _selectedIndex == 0 ? Colors.orange : Colors.grey,
                    onPressed: () => _onItemTapped(0),
                  ),
                  SizedBox(width: 100),
                  IconButton(
                    icon: Icon(Icons.list, size: 30),
                    color: _selectedIndex == 1 ? Colors.orange : Colors.grey,
                    onPressed: () => _onItemTapped(1),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: Container(
          height: 70.0,
          width: 70.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.deepPurple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: FloatingActionButton(
            onPressed: () {
              _showAddTaskDialog(context);
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Icon(Icons.add, size: 35),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
