import 'package:mini_games_alif/domain/entities/section.dart';
import 'package:mini_games_alif/data/models/level_model.dart';

class SectionModel extends Section {
  SectionModel({
    required super.id,
    required super.title,
    required super.description,
    required super.icon,
    required super.levels,
  });

  factory SectionModel.fromJson(Map<String, dynamic> json) {
    var levelsList = json['levels'] as List;
    List<LevelModel> levels =
        levelsList.map((levelJson) => LevelModel.fromJson(levelJson)).toList();

    return SectionModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      levels: levels,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'levels':
          (levels as List<LevelModel>).map((level) => level.toJson()).toList(),
    };
  }
}
