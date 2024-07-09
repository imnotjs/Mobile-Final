// lib/screens/exercise_list.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'add_exercise.dart';
import 'edit_exercise.dart';
import '../../models/exercise.dart';

class ExerciseList extends StatefulWidget {
  const ExerciseList({Key? key}) : super(key: key);

  @override
  State<ExerciseList> createState() => _ExerciseListState();
}

class _ExerciseListState extends State<ExerciseList> {
  late List<Exercise> _exercises;
  late Future<void> _loadedExercises;

  @override
  void initState() {
    super.initState();
    _loadedExercises = _loadExercises();
  }

  Future<void> _loadExercises() async {
    final url = Uri.https(
      'fit-track-test-default-rtdb.firebaseio.com',
      'exercise.json',
    );

    final response = await http.get(url);

    if (response.statusCode >= 400) {
      throw Exception('Failed to fetch data.');
    }

    final List<Exercise> loadedExercises = [];

    final Map<String, dynamic>? listExercises = json.decode(response.body);
    if (listExercises != null) {
      listExercises.forEach((key, value) {
        loadedExercises.add(Exercise.fromJson({
          'id': key,
          'title': value['title'],
          'details': value['details'],
          'duration': value['duration'] is int ? value['duration'] : int.parse(value['duration']),
        }));
      });
    }

    setState(() {
      _exercises = loadedExercises;
    });
  }

  Future<void> _addExercise() async {
    final newExercise = await Navigator.of(context).push<Exercise>(
      MaterialPageRoute(
        builder: (ctx) => const AddExercise(),
      ),
    );

    if (newExercise != null) {
      setState(() {
        _exercises.add(newExercise);
      });
    }
  }

  Future<void> _removeExercise(Exercise exercise) async {
    final url = Uri.https(
      'fit-track-test-default-rtdb.firebaseio.com',
      'exercise/${exercise.id}.json',
    );

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      throw Exception('Failed to delete exercise.');
    }

    setState(() {
      _exercises.remove(exercise);
    });
  }

  Future<void> _editExercise(Exercise exercise) async {
    final editedExercise = await Navigator.of(context).push<Exercise>(
      MaterialPageRoute(
        builder: (ctx) => EditExercise(exercise: exercise),
      ),
    );

    if (editedExercise != null) {
      // Update the exercise in _exercises list
      setState(() {
        final index = _exercises.indexWhere((ex) => ex.id == editedExercise.id);
        if (index != -1) {
          _exercises[index] = editedExercise;
        }
      });

      // Optionally, you can reload exercises after edit
      await _loadExercises();
    }
  }

  void _toggleExpansion(Exercise exercise) {
    setState(() {
      exercise.isExpanded = !exercise.isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise List'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 78, 13, 151),
              Color.fromARGB(255, 107, 15, 168),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _loadExercises,
          child: FutureBuilder(
            future: _loadedExercises,
            builder: (context, AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              } else if (_exercises.isEmpty) {
                return ListView(
                  // ListView to allow pull-to-refresh even if the list is empty
                  children: const [
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No exercises added yet!'),
                      ),
                    ),
                  ],
                );
              } else {
                return ListView.builder(
                  itemCount: _exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _exercises[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(exercise.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (exercise.isExpanded)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Details: ${exercise.details}'),
                                      Text('Duration: ${exercise.duration.toString()} minutes'),
                                      // Add more details here if needed
                                    ],
                                  ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(exercise.isExpanded ? Icons.expand_less : Icons.expand_more),
                              onPressed: () => _toggleExpansion(exercise),
                            ),
                          ),
                          if (exercise.isExpanded)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editExercise(exercise),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _removeExercise(exercise),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExercise,
        child: const Icon(Icons.add),
      ),
    );
  }
}
