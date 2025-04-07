import 'package:mini_games_alif/domain/models/game_model.dart';
import 'package:mini_games_alif/domain/models/level_model.dart';
import 'package:mini_games_alif/domain/models/question_model.dart';

class GameRepository {
  // Singleton instance
  static final GameRepository _instance = GameRepository._internal();
  factory GameRepository() => _instance;
  GameRepository._internal();

  // Mock data for the game
  final List<LevelModel> _levels = [
    LevelModel(
      gameId: 3,
      gameName: 'Number Line',
      sectionId: 1,
      sectionName: 'Numbers',
      subSectionId: 1,
      levelId: 1,
      subSectionName: 'Number range: 0 to 20',
      levelDescription: '0 to 10 by steps of 1',
      instructions:
          'Locate and choose the right number on the number line to solve each challenge.',
      gameDescription:
          'Solve number line challenges by placing numbers correctly to learn the concept of numerical order and values.',
      sectionDescription:
          'Solve number placement challenges by positioning whole numbers correctly to learn the concept of numerical order.',
      subSectionDescription:
          'Represent and arrange small numbers on a number line to learn the concept of counting.',
      gameIcon: 'Game Icon Number Line',
      sectionIcon: 'range_0_20',
      levelIcon: 'nb_01',
      minValue: 0,
      maxValue: 10,
      step: 1,
      isCompleted: false,
      stars: 0,
    ),
    LevelModel(
      gameId: 3,
      gameName: 'Number Line',
      sectionId: 1,
      sectionName: 'Numbers',
      subSectionId: 1,
      levelId: 2,
      subSectionName: 'Number range: 0 to 20',
      levelDescription: '10 to 20 by steps of 1',
      instructions:
          'Locate and choose the right number on the number line to solve each challenge.',
      gameDescription:
          'Solve number line challenges by placing numbers correctly to learn the concept of numerical order and values.',
      sectionDescription:
          'Solve number placement challenges by positioning whole numbers correctly to learn the concept of numerical order.',
      subSectionDescription:
          'Represent and arrange small numbers on a number line to learn the concept of counting.',
      gameIcon: 'Game Icon Number Line',
      sectionIcon: 'range_0_20',
      levelIcon: 'nb_02',
      minValue: 10,
      maxValue: 20,
      step: 1,
      isCompleted: false,
      stars: 0,
    ),
    LevelModel(
      gameId: 3,
      gameName: 'Number Line',
      sectionId: 1,
      sectionName: 'Numbers',
      subSectionId: 1,
      levelId: 3,
      subSectionName: 'Number range: 0 to 20',
      levelDescription: '0 to 20 by steps of 2',
      instructions:
          'Locate and choose the right number on the number line to solve each challenge.',
      gameDescription:
          'Solve number line challenges by placing numbers correctly to learn the concept of numerical order and values.',
      sectionDescription:
          'Solve number placement challenges by positioning whole numbers correctly to learn the concept of numerical order.',
      subSectionDescription:
          'Represent and arrange small numbers on a number line to learn the concept of counting.',
      gameIcon: 'Game Icon Number Line',
      sectionIcon: 'range_0_20',
      levelIcon: 'nb_03',
      minValue: 0,
      maxValue: 20,
      step: 2,
      isCompleted: false,
      stars: 0,
    ),
  ];

  // Get all levels
  List<LevelModel> getAllLevels() {
    return _levels;
  }

  // Get level by ID
  LevelModel? getLevelById(int levelId) {
    try {
      return _levels.firstWhere((level) => level.levelId == levelId);
    } catch (e) {
      return null;
    }
  }

  // Get levels by section
  List<LevelModel> getLevelsBySection(int sectionId) {
    return _levels.where((level) => level.sectionId == sectionId).toList();
  }

  // Get levels by subsection
  List<LevelModel> getLevelsBySubSection(int sectionId, int? subSectionId) {
    return _levels
        .where((level) =>
            level.sectionId == sectionId && level.subSectionId == subSectionId)
        .toList();
  }

  // Get unique games
  List<GameModel> getGames() {
    final Set<int> gameIds = _levels.map((level) => level.gameId).toSet();
    return gameIds.map((id) {
      final List<LevelModel> gameLevels =
          _levels.where((level) => level.gameId == id).toList();
      final GameModel game = GameModel(
        gameId: id,
        gameName: gameLevels.first.gameName,
        gameIcon: gameLevels.first.gameIcon,
        gameDescription: gameLevels.first.gameDescription,
        isUnlocked: true,
        completedLevels: gameLevels.where((level) => level.isCompleted).length,
        totalLevels: gameLevels.length,
        totalStars: gameLevels.fold(0, (sum, level) => sum + level.stars),
      );
      return game;
    }).toList();
  }

  // Get unique sections
  List<String> getSections() {
    return _levels.map((level) => level.sectionName).toSet().toList();
  }

  // Get questions for a level
  List<QuestionModel> getQuestionsForLevel(int levelId, {int count = 5}) {
    final level = getLevelById(levelId);
    if (level == null) return [];

    List<QuestionModel> questions = [];
    for (int i = 0; i < count; i++) {
      questions.add(QuestionModel.generateFromLevel(
        id: i + 1,
        minValue: level.minValue,
        maxValue: level.maxValue,
        step: level.step,
      ));
    }
    return questions;
  }

  // Update level completion status
  void updateLevelCompletion(int levelId, bool isCompleted, int stars) {
    final index = _levels.indexWhere((level) => level.levelId == levelId);
    if (index != -1) {
      _levels[index] = LevelModel(
        gameId: _levels[index].gameId,
        gameName: _levels[index].gameName,
        sectionId: _levels[index].sectionId,
        sectionName: _levels[index].sectionName,
        subSectionId: _levels[index].subSectionId,
        levelId: _levels[index].levelId,
        subSectionName: _levels[index].subSectionName,
        levelDescription: _levels[index].levelDescription,
        instructions: _levels[index].instructions,
        gameDescription: _levels[index].gameDescription,
        sectionDescription: _levels[index].sectionDescription,
        subSectionDescription: _levels[index].subSectionDescription,
        gameIcon: _levels[index].gameIcon,
        sectionIcon: _levels[index].sectionIcon,
        levelIcon: _levels[index].levelIcon,
        minValue: _levels[index].minValue,
        maxValue: _levels[index].maxValue,
        step: _levels[index].step,
        isCompleted: isCompleted,
        stars: stars,
      );
    }
  }
}
