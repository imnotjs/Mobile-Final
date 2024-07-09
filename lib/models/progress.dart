// lib/models/progress.dart

class Progress {
  final String id;
  final int month;
  final int year;
  final double weight;
  final double height;
  final double bodyFatPercentage;
  bool isExpanded; // Define isExpanded property

  Progress({
    required this.id,
    required this.month,
    required this.year,
    required this.weight,
    required this.height,
    required this.bodyFatPercentage,
    this.isExpanded = false, // Default value for isExpanded
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      id: json['id'],
      month: json['month'],
      year: json['year'],
      weight: json['weight'],
      height: json['height'],
      bodyFatPercentage: json['bodyFatPercentage'],
      isExpanded: false, // Initialize isExpanded when creating from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'month': month,
      'year': year,
      'weight': weight,
      'height': height,
      'bodyFatPercentage': bodyFatPercentage,
    };
  }
}
