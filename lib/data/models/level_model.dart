import 'package:mini_games_alif/domain/entities/level.dart';

class LevelModel extends Level {
  LevelModel({
    required super.id,
    required super.title,
    required super.description,
    required super.instructions,
    required super.startNumber,
    required super.endNumber,
    required super.step,
    required super.icon,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      instructions: json['instructions'],
      startNumber: json['startNumber'],
      endNumber: json['endNumber'],
      step: json['step'],
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'instructions': instructions,
      'startNumber': startNumber,
      'endNumber': endNumber,
      'step': step,
      'icon': icon,
    };
  }
}
