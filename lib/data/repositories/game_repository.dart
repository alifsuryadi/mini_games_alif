import 'package:mini_games_alif/domain/models/game_model.dart';
import 'package:mini_games_alif/domain/models/level_model.dart';
import 'package:mini_games_alif/domain/models/question_model.dart';

class GameRepository {
  // Singleton instance
  static final GameRepository _instance = GameRepository._internal();
  factory GameRepository() => _instance;
  GameRepository._internal();

  // Data for the game
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
          'Learn to place numbers on a number line to understand numerical order and values.',
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
          'Learn to place numbers on a number line to understand numerical order and values.',
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
          'Learn to place numbers on a number line to understand numerical order and values.',
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
    LevelModel(
      gameId: 3,
      gameName: 'Number Line',
      sectionId: 1,
      sectionName: 'Numbers',
      subSectionId: 2,
      levelId: 4,
      subSectionName: 'Number range: 0 to 100',
      levelDescription: '0 to 50 by steps of 5',
      instructions:
          'Locate and choose the right number on the number line to solve each challenge.',
      gameDescription:
          'Learn to place numbers on a number line to understand numerical order and values.',
      sectionDescription:
          'Solve number placement challenges by positioning whole numbers correctly to learn the concept of numerical order.',
      subSectionDescription:
          'Represent and arrange larger numbers on a number line to develop number sense.',
      gameIcon: 'Game Icon Number Line',
      sectionIcon: 'range_0_100',
      levelIcon: 'nb_04',
      minValue: 0,
      maxValue: 50,
      step: 5,
      isCompleted: false,
      stars: 0,
    ),
    LevelModel(
      gameId: 3,
      gameName: 'Number Line',
      sectionId: 1,
      sectionName: 'Numbers',
      subSectionId: 2,
      levelId: 5,
      subSectionName: 'Number range: 0 to 100',
      levelDescription: '50 to 100 by steps of 5',
      instructions:
          'Locate and choose the right number on the number line to solve each challenge.',
      gameDescription:
          'Learn to place numbers on a number line to understand numerical order and values.',
      sectionDescription:
          'Solve number placement challenges by positioning whole numbers correctly to learn the concept of numerical order.',
      subSectionDescription:
          'Represent and arrange larger numbers on a number line to develop number sense.',
      gameIcon: 'Game Icon Number Line',
      sectionIcon: 'range_0_100',
      levelIcon: 'nb_05',
      minValue: 50,
      maxValue: 100,
      step: 5,
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
      // Update current level
      _levels[index] = _levels[index].copyWith(
        isCompleted: isCompleted,
        stars: stars,
      );

      // If this level is completed successfully, unlock the next level
      if (isCompleted && index < _levels.length - 1) {
        // Only update the next level if it's not already completed
        if (!_levels[index + 1].isCompleted) {
          _levels[index + 1] = _levels[index + 1].copyWith(
            isUnlocked: true,
          );
        }
      }
    }
  }
}
