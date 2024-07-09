// lib/screens/edit_meal.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/meal.dart';

class EditMeal extends StatefulWidget {
  final Meal meal;

  const EditMeal({Key? key, required this.meal}) : super(key: key);

  @override
  _EditMealState createState() => _EditMealState();
}

class _EditMealState extends State<EditMeal> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _caloriesController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.meal.title);
    _descriptionController = TextEditingController(text: widget.meal.description);
    _caloriesController = TextEditingController(text: widget.meal.calories.toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _saveMeal() async {
    final editedMeal = Meal(
      id: widget.meal.id,
      title: _titleController.text,
      description: _descriptionController.text,
      calories: int.tryParse(_caloriesController.text) ?? 0,
    );

    final url = Uri.https(
      'fit-track-test-default-rtdb.firebaseio.com',
      'meals/${widget.meal.id}.json',
    );

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': editedMeal.title,
          'description': editedMeal.description,
          'calories': editedMeal.calories,
        }),
      );

      if (response.statusCode >= 400) {
        throw Exception('Failed to update meal.');
      }

      Navigator.of(context).pop(editedMeal); // Close edit screen on success
    } catch (error) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An Error Occurred!'),
          content: Text('Failed to update meal. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Meal'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: null, // Allow the TextField to expand vertically
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _caloriesController,
                decoration: const InputDecoration(labelText: 'Calories'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: ElevatedButton.icon(
                  onPressed: _saveMeal,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    'Save Changes',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 107, 15, 168), // Set to second color
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Adjust button corner radius
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
