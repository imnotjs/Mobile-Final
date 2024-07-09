// lib/screens/progress/edit_progress.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/progress.dart';

class EditProgress extends StatefulWidget {
  final Progress progress;

  const EditProgress({Key? key, required this.progress}) : super(key: key);

  @override
  _EditProgressState createState() => _EditProgressState();
}

class _EditProgressState extends State<EditProgress> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _bodyFatPercentageController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: widget.progress.weight.toString());
    _heightController = TextEditingController(text: widget.progress.height.toString());
    _bodyFatPercentageController = TextEditingController(text: widget.progress.bodyFatPercentage.toString());
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _bodyFatPercentageController.dispose();
    super.dispose();
  }

  Future<void> _saveProgress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedProgress = Progress(
      id: widget.progress.id,
      month: widget.progress.month,
      year: widget.progress.year,
      weight: double.parse(_weightController.text),
      height: double.parse(_heightController.text),
      bodyFatPercentage: double.parse(_bodyFatPercentageController.text),
    );

    final url = Uri.https(
      'fit-track-test-default-rtdb.firebaseio.com',
      'progress/${widget.progress.id}.json',
    );

    final response = await http.patch(
      url,
      body: json.encode({
        'weight': updatedProgress.weight,
        'height': updatedProgress.height,
        'bodyFatPercentage': updatedProgress.bodyFatPercentage,
      }),
    );

    if (response.statusCode >= 400) {
      throw Exception('Failed to update progress.');
    }

    Navigator.of(context).pop(updatedProgress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Progress'),
      ),
      body: Container(
        color: Colors.white, // Set background color to white
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                TextFormField(
                  controller: _weightController,
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter weight.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _heightController,
                  decoration: const InputDecoration(labelText: 'Height (cm)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter height.';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _bodyFatPercentageController,
                  decoration: const InputDecoration(labelText: 'Body Fat Percentage (%)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter body fat percentage.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: ElevatedButton.icon(
                    onPressed: _saveProgress,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      'Save Changes',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 107, 15, 168), // Set to second color
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
