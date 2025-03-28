import 'package:get/get.dart';
import 'package:mini_games_alif/data/repositories/gcf_level_repository.dart';
import 'package:mini_games_alif/domain/entities/gcf_level.dart';
import 'dart:math';

class GCFChallengeController extends GetxController {
  final GCFLevelRepository _levelRepository = GCFLevelRepository();

  final RxList<GCFLevel> levels = <GCFLevel>[].obs;
  final Rx<GCFLevel?> currentLevel = Rx<GCFLevel?>(null);

  final RxInt value1 = 0.obs;
  final RxInt value2 = 0.obs;
  final RxBool isCorrect = false.obs;
  final RxInt selectedAnswer = 0.obs;
  final RxInt correctAnswer = 0.obs;

  final RxInt minRange = 0.obs;
  final RxInt maxRange = 0.obs;
  final RxInt rangeWidth = 10.obs;

  final Random _random = Random();

  @override
  void onInit() {
    super.onInit();
    levels.value = _levelRepository.getLevels();
    if (levels.isNotEmpty) {
      setLevel(levels[0]);
    }
  }

  void setLevel(GCFLevel level) {
    currentLevel.value = level;
    minRange.value = level.minRange;
    maxRange.value = level.maxRange;
    rangeWidth.value = level.rangeWidth;
    generateChallenge();
  }

  void generateChallenge() {
    // Generate two numbers within the level's range with a known GCF
    int minFactor = 2; // Minimum GCF
    int maxFactor =
        min(20, (maxRange.value - minRange.value) ~/ 5); // Maximum GCF

    // Ensure maxFactor is at least minFactor
    maxFactor = max(minFactor, maxFactor);

    // Select a random GCF between minFactor and maxFactor
    int gcf = minFactor + _random.nextInt(maxFactor - minFactor + 1);

    // Generate multiples of the GCF within the range
    int maxMultiple = maxRange.value ~/ gcf;
    int minMultiple = max(1, minRange.value ~/ gcf);

    // Ensure there are at least a few multiples to choose from
    if (maxMultiple <= minMultiple + 1) {
      minMultiple = max(1, minMultiple - 1);
      maxMultiple = minMultiple + 2;
    }

    // Select two different random multiples
    int multiple1 = minMultiple + _random.nextInt(maxMultiple - minMultiple);
    int multiple2 = minMultiple + _random.nextInt(maxMultiple - minMultiple);

    // Ensure they're different
    while (multiple2 == multiple1) {
      multiple2 = minMultiple + _random.nextInt(maxMultiple - minMultiple);
    }

    value1.value = gcf * multiple1;
    value2.value = gcf * multiple2;
    correctAnswer.value = gcf;
    isCorrect.value = false;
    selectedAnswer.value = 0;
  }

  void checkAnswer(int answer) {
    selectedAnswer.value = answer;
    isCorrect.value = answer == correctAnswer.value;

    if (isCorrect.value) {
      // Show success feedback
      Future.delayed(const Duration(seconds: 2), () {
        generateChallenge();
      });
    }
  }
}
