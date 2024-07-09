// lib/screens/add_exercise.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/exercise.dart';

class AddExercise extends StatefulWidget {
  const AddExercise({Key? key}) : super(key: key);

  @override
  State<AddExercise> createState() => _AddExerciseState();
}

class _AddExerciseState extends State<AddExercise> {
  final _formKey = GlobalKey<FormState>();
  var _enteredTitle = '';
  var _enteredDetails = '';
  var _enteredDuration = '';
  var _isSending = false;

  void _saveExercise() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isSending = true;
      });

      final url = Uri.https(
        'fit-track-test-default-rtdb.firebaseio.com',
        'exercise.json',
      );

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'title': _enteredTitle,
            'details': _enteredDetails,
            'duration': _enteredDuration,
          }),
        );

        final Map<String, dynamic> resData = json.decode(response.body);

        if (!context.mounted) return;

        Navigator.of(context).pop(
          Exercise(
            id: resData['name'],
            title: _enteredTitle,
            details: _enteredDetails,
            duration: int.parse(_enteredDuration),
          ),
        );
      } catch (error) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An Error Occurred!'),
            content: Text('Failed to save exercise. Please try again.'),
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
        title: const Text('Add a New Exercise'),
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
                  labelText: 'Details',
                ),
                maxLines: null, // Allow the TextFormField to expand vertically
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter details.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredDetails = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      int.tryParse(value) == null ||
                      int.parse(value) <= 0) {
                    return 'Please enter a valid duration.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredDuration = value!;
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
                    onPressed: _isSending ? null : _saveExercise,
                    child: _isSending
                        ? SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(),
                    )
                        : const Text('Add Exercise'),
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
