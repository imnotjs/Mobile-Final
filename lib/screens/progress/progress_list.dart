// lib/screens/progress/progress_list.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'add_progress.dart';
import 'edit_progress.dart';
import '../../models/progress.dart';
import 'package:intl/intl.dart'; // Import DateFormat for date formatting

class ProgressList extends StatefulWidget {
  const ProgressList({Key? key}) : super(key: key);

  @override
  State<ProgressList> createState() => _ProgressListState();
}

class _ProgressListState extends State<ProgressList> {
  late List<Progress> _progresses;
  late Future<void> _loadedProgresses;

  @override
  void initState() {
    super.initState();
    _loadedProgresses = _loadProgresses();
  }

  Future<void> _loadProgresses() async {
    final url = Uri.https(
      'fit-track-test-default-rtdb.firebaseio.com',
      'progress.json',
    );

    final response = await http.get(url);

    if (response.statusCode >= 400) {
      throw Exception('Failed to fetch data.');
    }

    final List<Progress> loadedProgresses = [];

    final Map<String, dynamic>? listProgresses = json.decode(response.body);
    if (listProgresses != null) {
      listProgresses.forEach((key, value) {
        loadedProgresses.add(Progress.fromJson({
          'id': key,
          'month': value['month'],
          'year': value['year'],
          'weight': value['weight'],
          'height': value['height'],
          'bodyFatPercentage': value['bodyFatPercentage'],
        }));
      });
    }

    setState(() {
      _progresses = loadedProgresses;
    });
  }

  Future<void> _addProgress() async {
    final newProgress = await Navigator.of(context).push<Progress>(
      MaterialPageRoute(
        builder: (ctx) => const AddProgress(),
      ),
    );

    if (newProgress != null) {
      setState(() {
        _progresses.add(newProgress);
      });
    }
  }

  Future<void> _removeProgress(Progress progress) async {
    final url = Uri.https(
      'fit-track-test-default-rtdb.firebaseio.com',
      'progress/${progress.id}.json',
    );

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      throw Exception('Failed to delete progress.');
    }

    setState(() {
      _progresses.remove(progress);
    });
  }

  Future<void> _editProgress(Progress progress) async {
    final editedProgress = await Navigator.of(context).push<Progress>(
      MaterialPageRoute(
        builder: (ctx) => EditProgress(progress: progress),
      ),
    );

    if (editedProgress != null) {
      // Update the progress in _progresses list
      setState(() {
        final index = _progresses.indexWhere((pg) => pg.id == editedProgress.id);
        if (index != -1) {
          _progresses[index] = editedProgress;
        }
      });

      // Optionally, you can reload progresses after edit
      await _loadProgresses();
    }
  }

  void _toggleExpansion(Progress progress) {
    setState(() {
      progress.isExpanded = !progress.isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress List'),
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
          onRefresh: _loadProgresses,
          child: FutureBuilder(
            future: _loadedProgresses,
            builder: (context, AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              } else if (_progresses.isEmpty) {
                return ListView(
                  // ListView to allow pull-to-refresh even if the list is empty
                  children: const [
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No progress records added yet!'),
                      ),
                    ),
                  ],
                );
              } else {
                return ListView.builder(
                  itemCount: _progresses.length,
                  itemBuilder: (context, index) {
                    final progress = _progresses[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text('${DateFormat.MMMM().format(DateTime(progress.year, progress.month))} ${progress.year}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (progress.isExpanded)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Weight: ${progress.weight} kg'),
                                      Text('Height: ${progress.height} cm'),
                                      Text('Body Fat Percentage: ${progress.bodyFatPercentage}%'),
                                    ],
                                  ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(progress.isExpanded ? Icons.expand_less : Icons.expand_more),
                              onPressed: () => _toggleExpansion(progress),
                            ),
                            onTap: () => _toggleExpansion(progress), // Toggle on tap
                          ),
                          if (progress.isExpanded)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editProgress(progress),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _removeProgress(progress),
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
        onPressed: _addProgress,
        child: const Icon(Icons.add),
      ),
    );
  }
}
