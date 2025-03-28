import 'package:mini_games_alif/domain/entities/level.dart';

class Section {
  final int id;
  final String title;
  final String description;
  final String icon;
  final List<Level> levels;

  Section({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.levels,
  });
}
