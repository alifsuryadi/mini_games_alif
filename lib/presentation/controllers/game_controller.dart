import 'package:get/get.dart';
import 'package:mini_games_alif/domain/entities/level.dart';
import 'package:mini_games_alif/domain/entities/section.dart';
import 'package:mini_games_alif/domain/entities/game_challenge.dart';
import 'package:mini_games_alif/domain/usecases/get_game_sections_usecase.dart';
import 'package:mini_games_alif/domain/usecases/generate_challenges_usecase.dart';
import 'package:mini_games_alif/data/repositories/level_repository.dart';

class GameController extends GetxController {
  final LevelRepository _levelRepository = LevelRepository();
  late final GetGameSectionsUseCase _getGameSectionsUseCase;
  late final GenerateChallengesUseCase _generateChallengesUseCase;

  // Observable variables
  final RxList<Section> sections = <Section>[].obs;
  final Rx<Section?> currentSection = Rx<Section?>(null);
  final Rx<Level?> currentLevel = Rx<Level?>(null);
  final RxList<GameChallenge> challenges = <GameChallenge>[].obs;
  final RxInt currentChallengeIndex = 0.obs;
  final RxInt score = 0.obs;
  final RxBool isGameCompleted = false.obs;
  final RxBool isCorrectAnswer = false.obs;

  @override
  void onInit() {
    super.onInit();
    _getGameSectionsUseCase = GetGameSectionsUseCase(_levelRepository);
    _generateChallengesUseCase = GenerateChallengesUseCase(_levelRepository);
    loadGameSections();
  }

  void loadGameSections() {
    sections.value = _getGameSectionsUseCase.execute();
    if (sections.isNotEmpty) {
      currentSection.value = sections[0];
    }
  }

  void selectLevel(Level level) {
    currentLevel.value = level;
    resetGame();
    generateChallenges(5); // Generate 5 challenges for the selected level
  }

  void generateChallenges(int count) {
    if (currentLevel.value != null) {
      challenges.value =
          _generateChallengesUseCase.execute(currentLevel.value!, count);
      currentChallengeIndex.value = 0;
    }
  }

  GameChallenge? getCurrentChallenge() {
    if (challenges.isEmpty ||
        currentChallengeIndex.value >= challenges.length) {
      return null;
    }
    return challenges[currentChallengeIndex.value];
  }

  bool checkAnswer(int selectedNumber) {
    GameChallenge? challenge = getCurrentChallenge();
    if (challenge == null) return false;

    bool isCorrect = selectedNumber == challenge.targetNumber;
    if (isCorrect) {
      score.value++;
      isCorrectAnswer.value = true;
    } else {
      isCorrectAnswer.value = false;
    }

    // Move to the next challenge or complete the game
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (currentChallengeIndex.value < challenges.length - 1) {
        currentChallengeIndex.value++;
      } else {
        isGameCompleted.value = true;
      }
      isCorrectAnswer.value = false;
    });

    return isCorrect;
  }

  void resetGame() {
    challenges.clear();
    currentChallengeIndex.value = 0;
    score.value = 0;
    isGameCompleted.value = false;
    isCorrectAnswer.value = false;
  }
}
