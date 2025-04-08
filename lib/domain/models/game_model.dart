class GameModel {
  final int gameId;
  final String gameName;
  final String gameIcon;
  final String gameDescription;
  final bool isUnlocked;
  final int completedLevels;
  final int totalLevels;
  final int totalStars;

  GameModel({
    required this.gameId,
    required this.gameName,
    required this.gameIcon,
    required this.gameDescription,
    this.isUnlocked = false,
    this.completedLevels = 0,
    this.totalLevels = 0,
    this.totalStars = 0,
  });

  double get completionPercentage {
    if (totalLevels == 0) return 0.0;
    return completedLevels / totalLevels;
  }
}
