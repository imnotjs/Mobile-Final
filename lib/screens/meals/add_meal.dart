// lib/screens/add_meal.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/meal.dart';

class AddMeal extends StatefulWidget {
  const AddMeal({Key? key}) : super(key: key);

  @override
  State<AddMeal> createState() => _AddMealState();
}

class _AddMealState extends State<AddMeal> {
  final _formKey = GlobalKey<FormState>();
  var _enteredTitle = '';
  var _enteredDescription = '';
  var _enteredCalories = '';
  var _isSending = false;

  void _saveMeal() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isSending = true;
      });

      final url = Uri.https(
        'fit-track-test-default-rtdb.firebaseio.com',
        'meals.json',
      );

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'title': _enteredTitle,
            'description': _enteredDescription,
            'calories': _enteredCalories,
          }),
        );

        final Map<String, dynamic> resData = json.decode(response.body);

        if (!context.mounted) return;

        Navigator.of(context).pop(
          Meal(
            id: resData['name'],
            title: _enteredTitle,
            description: _enteredDescription,
            calories: int.parse(_enteredCalories),
          ),
        );
      } catch (error) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An Error Occurred!'),
            content: Text('Failed to save meal. Please try again.'),
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
      } finally {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a New Meal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredTitle = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                maxLines: null, // Allow the TextFormField to expand vertically
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredDescription = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Calories',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      int.tryParse(value) == null ||
                      int.parse(value) <= 0) {
                    return 'Please enter a valid number of calories.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredCalories = value!;
                },
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                          },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _isSending ? null : _saveMeal,
                    child: _isSending
                        ? SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Add Meal'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
