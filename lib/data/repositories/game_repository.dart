import 'package:mini_games_alif/core/utils/level_parser.dart';
import 'package:mini_games_alif/domain/models/game_model.dart';
import 'package:mini_games_alif/domain/models/level_model.dart';
import 'package:mini_games_alif/domain/models/question_model.dart';

class GameRepository {
  // Singleton instance
  static final GameRepository _instance = GameRepository._internal();
  factory GameRepository() => _instance;
  GameRepository._internal();

  // Flag to track if levels have been loaded from file
  bool _isInitialized = false;

  // Data for the game
  List<LevelModel> _levels = [
    // Default levels that may be overridden when loading from Excel
    LevelModel(
      gameId: 3,
      gameName: 'Number Line',
      sectionId: 0,
      sectionName: 'Tutorial',
      subSectionId: 0,
      levelId: 0,
      subSectionName: 'Getting Started',
      levelDescription: 'Learn how to play',
      instructions: 'Follow the tutorial to learn how to use the number line',
      gameDescription:
          'Learn to place numbers on a number line to understand numerical order and values.',
      sectionDescription:
          'Tutorial to help you get started with the Number Line game.',
      subSectionDescription:
          'Learn the basics of using the number line interface.',
      gameIcon: 'Game Icon Number Line',
      sectionIcon: 'tutorial',
      levelIcon: 'tutorial',
      minValue: 0,
      maxValue: 10,
      step: 1,
      isCompleted: false,
      isUnlocked: true,
      stars: 0,
    ),
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
      isUnlocked: true,
      stars: 0,
    ),
    // Other default levels...
  ];

  // Initialize repository with data from Excel file
  Future<void> initialize(String excelPath) async {
    if (_isInitialized) return;

    final LevelParser parser = LevelParser();
    final parsedLevels = await parser.parseLevelData(excelPath);

    if (parsedLevels.isNotEmpty) {
      _levels = parsedLevels;
    }

    _isInitialized = true;
  }

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

      // Skip tutorial level for game progress calculation
      final List<LevelModel> nonTutorialLevels =
          gameLevels.where((level) => level.levelId != 0).toList();

      final GameModel game = GameModel(
        gameId: id,
        gameName: gameLevels.first.gameName,
        gameIcon: gameLevels.first.gameIcon,
        gameDescription: gameLevels.first.gameDescription,
        isUnlocked: true,
        completedLevels:
            nonTutorialLevels.where((level) => level.isCompleted).length,
        totalLevels: nonTutorialLevels.length,
        totalStars:
            nonTutorialLevels.fold(0, (sum, level) => sum + level.stars),
      );
      return game;
    }).toList();
  }

  // Get unique sections, excluding tutorial
  List<String> getSections() {
    return _levels
        .where((level) => level.sectionId != 0) // Exclude tutorial section
        .map((level) => level.sectionName)
        .toSet()
        .toList();
  }

  // Get questions for a level
  List<QuestionModel> getQuestionsForLevel(int levelId, {int count = 5}) {
    final level = getLevelById(levelId);
    if (level == null) return [];

    // For tutorial level, create specific tutorial questions
    if (levelId == 0) {
      return [
        QuestionModel.tutorial(
          id: 1,
          question: 'Place the marker on the number 5',
          correctAnswer: 5,
          numberLineValues: List.generate(11, (index) => index),
          minValue: 0,
          maxValue: 10,
          step: 1,
          tutorialType: 'marker_placement',
        ),
        QuestionModel.tutorial(
          id: 2,
          question: 'What is 2 + 3?',
          correctAnswer: 5,
          numberLineValues: List.generate(11, (index) => index),
          minValue: 0,
          maxValue: 10,
          step: 1,
          tutorialType: 'addition',
          operand1: 2,
          operand2: 3,
        ),
        QuestionModel.tutorial(
          id: 3,
          question: 'What is 7 - 2?',
          correctAnswer: 5,
          numberLineValues: List.generate(11, (index) => index),
          minValue: 0,
          maxValue: 10,
          step: 1,
          tutorialType: 'subtraction',
          operand1: 7,
          operand2: 2,
        ),
      ];
    }

    // For regular levels, generate questions based on level parameters
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
      // Skip unlocking next level for tutorial
      if (levelId == 0) {
        _levels[index] = _levels[index].copyWith(
          isCompleted: isCompleted,
          stars: stars,
        );
        return;
      }

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
