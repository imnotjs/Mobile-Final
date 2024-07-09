import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/exercise.dart';
import 'package:http/http.dart' as http;

class EditExercise extends StatefulWidget {
  final Exercise exercise;

  const EditExercise({Key? key, required this.exercise}) : super(key: key);

  @override
  _EditExerciseState createState() => _EditExerciseState();
}

class _EditExerciseState extends State<EditExercise> {
  late TextEditingController _titleController;
  late TextEditingController _detailsController;
  late TextEditingController _durationController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.exercise.title);
    _detailsController = TextEditingController(text: widget.exercise.details);
    _durationController = TextEditingController(text: widget.exercise.duration.toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _saveExercise() async {
    final editedExercise = Exercise(
      id: widget.exercise.id,
      title: _titleController.text,
      details: _detailsController.text,
      duration: int.tryParse(_durationController.text) ?? 0,
    );

    final url = Uri.https(
      'fit-track-test-default-rtdb.firebaseio.com',
      'exercise/${widget.exercise.id}.json',
    );

    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': editedExercise.title,
          'details': editedExercise.details,
          'duration': editedExercise.duration,
        }),
      );

      if (response.statusCode >= 400) {
        throw Exception('Failed to update exercise.');
      }

      Navigator.of(context).pop(editedExercise); // Close edit screen on success
    } catch (error) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An Error Occurred!'),
          content: Text('Failed to update exercise. Please try again.'),
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
        title: const Text('Edit Exercise'),
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
                controller: _detailsController,
                decoration: const InputDecoration(labelText: 'Details'),
                maxLines: null, // Allow the TextField to expand vertically
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _durationController,
                decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: ElevatedButton.icon(
                  onPressed: _saveExercise,
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
