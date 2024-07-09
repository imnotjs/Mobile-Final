// lib/models/meal.dart

class Meal {
  final String id;
  final String title;
  final String description;
  final int calories;
  bool isExpanded; // New property for expansion state

  Meal({
    required this.id,
    required this.title,
    required this.description,
    required this.calories,
    this.isExpanded = false, // Default value for isExpanded
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      calories: json['calories'] is int ? json['calories'] : int.parse(json['calories']),
      isExpanded: false, // Initialize isExpanded when creating from JSON
    );
  }
}
