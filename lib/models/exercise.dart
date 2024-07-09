// lib/models/exercise.dart

class Exercise {
  final String id;
  final String title;
  final String details;
  final int duration;
  bool isExpanded; // New property for expansion state

  Exercise({
    required this.id,
    required this.title,
    required this.details,
    required this.duration,
    this.isExpanded = false, // Default value for isExpanded
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'],
      title: json['title'],
      details: json['details'],
      duration: json['duration'] is int ? json['duration'] : int.parse(json['duration']),
      isExpanded: false, // Initialize isExpanded when creating from JSON
    );
  }
}
