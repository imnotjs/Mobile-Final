// lib/screens/meal_list.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'add_meal.dart';
import 'edit_meal.dart';
import '../../models/meal.dart';

class MealList extends StatefulWidget {
  const MealList({Key? key}) : super(key: key);

  @override
  State<MealList> createState() => _MealListState();
}

class _MealListState extends State<MealList> {
  late List<Meal> _meals;
  late Future<void> _loadedMeals;

  @override
  void initState() {
    super.initState();
    _loadedMeals = _loadMeals();
  }

  Future<void> _loadMeals() async {
    final url = Uri.https(
      'fit-track-test-default-rtdb.firebaseio.com',
      'meals.json',
    );

    final response = await http.get(url);

    if (response.statusCode >= 400) {
      throw Exception('Failed to fetch data.');
    }

    final List<Meal> loadedMeals = [];

    final Map<String, dynamic>? listMeals = json.decode(response.body);
    if (listMeals != null) {
      listMeals.forEach((key, value) {
        loadedMeals.add(Meal.fromJson({
          'id': key,
          'title': value['title'],
          'description': value['description'],
          'calories': value['calories'] is int ? value['calories'] : int.parse(value['calories']),
        }));
      });
    }

    setState(() {
      _meals = loadedMeals;
    });
  }

  Future<void> _addMeal() async {
    final newMeal = await Navigator.of(context).push<Meal>(
      MaterialPageRoute(
        builder: (ctx) => const AddMeal(),
      ),
    );

    if (newMeal != null) {
      setState(() {
        _meals.add(newMeal);
      });
    }
  }

  Future<void> _removeMeal(Meal meal) async {
    final url = Uri.https(
      'fit-track-test-default-rtdb.firebaseio.com',
      'meals/${meal.id}.json',
    );

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      throw Exception('Failed to delete meal.');
    }

    setState(() {
      _meals.remove(meal);
    });
  }

  Future<void> _editMeal(Meal meal) async {
    final editedMeal = await Navigator.of(context).push<Meal>(
      MaterialPageRoute(
        builder: (ctx) => EditMeal(meal: meal),
      ),
    );

    if (editedMeal != null) {
      // Update the meal in _meals list
      setState(() {
        final index = _meals.indexWhere((ml) => ml.id == editedMeal.id);
        if (index != -1) {
          _meals[index] = editedMeal;
        }
      });

      // Optionally, you can reload meals after edit
      await _loadMeals();
    }
  }

  void _toggleExpansion(Meal meal) {
    setState(() {
      meal.isExpanded = !meal.isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal List'),
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
          onRefresh: _loadMeals,
          child: FutureBuilder(
            future: _loadedMeals,
            builder: (context, AsyncSnapshot<void> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              } else if (_meals.isEmpty) {
                return ListView(
                  // ListView to allow pull-to-refresh even if the list is empty
                  children: const [
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No meals added yet!'),
                      ),
                    ),
                  ],
                );
              } else {
                return ListView.builder(
                  itemCount: _meals.length,
                  itemBuilder: (context, index) {
                    final meal = _meals[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(meal.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (meal.isExpanded)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Description: ${meal.description}'),
                                      Text('Calories: ${meal.calories.toString()} kcal'),
                                      // Add more details here if needed
                                    ],
                                  ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(meal.isExpanded ? Icons.expand_less : Icons.expand_more),
                              onPressed: () => _toggleExpansion(meal),
                            ),
                          ),
                          if (meal.isExpanded)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editMeal(meal),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _removeMeal(meal),
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
        onPressed: _addMeal,
        child: const Icon(Icons.add),
      ),
    );
  }
}
