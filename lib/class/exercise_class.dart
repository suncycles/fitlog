class Exercise {
  final int? id;
  final String name;
  final String primaryMuscles;
  final String secondaryMuscles;
  final String equipment;
  final String instructions;
  final String imageNames;

  Exercise({
    this.id,
    required this.name,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.equipment,
    required this.instructions,
    required this.imageNames,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: json['exercise_id'],
        name: json['exercise_name'],
        primaryMuscles: json['primary_muscles'],
        secondaryMuscles: json['secondary_muscles'],
        equipment: json['equipment'],
        instructions: json['instructions'],
        imageNames: json['image_names'],
      );

  Map<String, dynamic> toJson() => {
        'exercise_id': id,
        'exercise_name': name,
        'primary_muscles': primaryMuscles,
        'secondary_muscles': secondaryMuscles,
        'equipment': equipment,
        'instructions': instructions,
        'image_names': imageNames,
      };
}
