class LevelModel {
  final int gameId;
  final String gameName;
  final int sectionId;
  final String sectionName;
  final int? subSectionId;
  final int levelId;
  final String subSectionName;
  final String levelDescription;
  final String instructions;
  final String gameDescription;
  final String sectionDescription;
  final String subSectionDescription;
  final String gameIcon;
  final String sectionIcon;
  final String levelIcon;
  final int minValue;
  final int maxValue;
  final int step;
  final bool isCompleted;
  final int stars;

  LevelModel({
    required this.gameId,
    required this.gameName,
    required this.sectionId,
    required this.sectionName,
    this.subSectionId,
    required this.levelId,
    required this.subSectionName,
    required this.levelDescription,
    required this.instructions,
    required this.gameDescription,
    required this.sectionDescription,
    required this.subSectionDescription,
    required this.gameIcon,
    required this.sectionIcon,
    required this.levelIcon,
    required this.minValue,
    required this.maxValue,
    required this.step,
    this.isCompleted = false,
    this.stars = 0,
  });

  factory LevelModel.fromMap(Map<String, dynamic> map) {
    return LevelModel(
      gameId: map['N-Game'] ?? 0,
      gameName: map['Game'] ?? '',
      sectionId: map['N-Section'] ?? 0,
      sectionName: map['Section'] ?? '',
      subSectionId: map['N-SubSection'],
      levelId: map['Level'] ?? 0,
      subSectionName: map['Sub-section'] ?? '',
      levelDescription: map['Level desc'] ?? '',
      instructions: map['instructions'] ?? '',
      gameDescription: map['Game desc'] ?? '',
      sectionDescription: map['Section desc'] ?? '',
      subSectionDescription: map['Sub-section desc'] ?? '',
      gameIcon: map['game icon'] ?? '',
      sectionIcon: map['section icon'] ?? '',
      levelIcon: map['level icon'] ?? '',
      minValue: _parseMinValue(map['Level desc'] ?? ''),
      maxValue: _parseMaxValue(map['Level desc'] ?? ''),
      step: _parseStep(map['Level desc'] ?? ''),
      isCompleted: false,
      stars: 0,
    );
  }

  static int _parseMinValue(String desc) {
    try {
      final parts = desc.split('to');
      if (parts.length < 2) return 0;
      return int.parse(parts[0].trim());
    } catch (e) {
      return 0;
    }
  }

  static int _parseMaxValue(String desc) {
    try {
      final parts = desc.split('to');
      if (parts.length < 2) return 10;
      final maxPart = parts[1].split('by')[0].trim();
      return int.parse(maxPart);
    } catch (e) {
      return 10;
    }
  }

  static int _parseStep(String desc) {
    try {
      if (!desc.contains('by steps of')) return 1;
      final stepPart = desc.split('by steps of')[1].trim();
      return int.parse(stepPart);
    } catch (e) {
      return 1;
    }
  }
}
