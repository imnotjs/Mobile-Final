// lib/screens/progress/add_progress.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/progress.dart';

class AddProgress extends StatefulWidget {
  const AddProgress({Key? key}) : super(key: key);

  @override
  _AddProgressState createState() => _AddProgressState();
}

class _AddProgressState extends State<AddProgress> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _bodyFatPercentageController = TextEditingController();
  var _isSending = false;

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

    setState(() {
      _isSending = true;
    });

    final now = DateTime.now();
    final month = now.month;
    final year = now.year;

    final newProgress = Progress(
      id: DateTime.now().toString(),
      month: month,
      year: year,
      weight: double.parse(_weightController.text),
      height: double.parse(_heightController.text),
      bodyFatPercentage: double.parse(_bodyFatPercentageController.text),
    );

    final url = Uri.https(
      'fit-track-test-default-rtdb.firebaseio.com',
      'progress.json',
    );

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'month': newProgress.month,
          'year': newProgress.year,
          'weight': newProgress.weight,
          'height': newProgress.height,
          'bodyFatPercentage': newProgress.bodyFatPercentage,
        }),
      );

      if (response.statusCode >= 400) {
        throw Exception('Failed to save progress.');
      }

      Navigator.of(context).pop(newProgress);
    } catch (error) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An Error Occurred!'),
          content: Text('Failed to save progress. Please try again.'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Progress'),
      ),
      body: Padding(
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
                    onPressed: _isSending ? null : _saveProgress,
                    child: _isSending
                        ? SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Add Progress'),
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
