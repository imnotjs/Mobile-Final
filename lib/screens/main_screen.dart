import 'package:flutter/material.dart';
import 'exercise/exercise_list.dart';
import 'exercise/add_exercise.dart';
import 'meals/meal_list.dart';
import 'meals/add_meal.dart';
import 'progress/progress_list.dart'; // Import ProgressList screen
import 'progress/add_progress.dart'; // Import AddProgress screen

class TelemetryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Telemetry Page Placeholder'));
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    ExerciseList(),
    MealList(),
    ProgressList(), // Replace ProgressPage placeholder with ProgressList()
    TelemetryPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToAddExercise(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddExercise()),
    );
  }

  void _navigateToAddMeal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddMeal()),
    );
  }

  void _navigateToAddProgress(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddProgress()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('fit_track'),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      floatingActionButton: _selectedIndex == 0 || _selectedIndex == 1 || _selectedIndex == 2 // Show FAB for ExerciseList, MealList, and ProgressList
          ? FloatingActionButton(
              onPressed: () {
                if (_selectedIndex == 0) {
                  _navigateToAddExercise(context);
                } else if (_selectedIndex == 1) {
                  _navigateToAddMeal(context);
                } else if (_selectedIndex == 2) {
                  _navigateToAddProgress(context);
                }
              },
              backgroundColor: const Color.fromARGB(255, 223, 191, 248), // Light purple background
              child: const Icon(
                Icons.add,
                color: Color.fromARGB(255, 107, 15, 168), // Dark purple icon
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Exercise',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Meals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'Telemetry',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(255, 107, 15, 168), // Dark purple selected item color
        unselectedItemColor: Colors.black.withOpacity(0.6), // Unselected item color
        backgroundColor: const Color.fromARGB(255, 223, 191, 248), // Light purple background
        onTap: _onItemTapped,
      ),
    );
  }
}
