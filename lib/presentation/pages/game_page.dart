// lib/presentation/pages/game_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mini_games_alif/core/utils/number_line_utils.dart';
import 'package:mini_games_alif/domain/entities/game_challenge.dart';
import 'package:mini_games_alif/presentation/controllers/game_controller.dart';
import 'package:mini_games_alif/presentation/widgets/number_line.dart';
import 'package:mini_games_alif/presentation/widgets/game_completed_dialog.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final GameController gameController = Get.find<GameController>();

    return Scaffold(
      appBar: AppBar(
        title: Obx(
            () => Text('Level ${gameController.currentLevel.value?.id ?? 1}')),
        backgroundColor: const Color(0xFF3F51B5),
      ),
      body: Obx(() {
        final currentChallenge = gameController.getCurrentChallenge();
        final level = gameController.currentLevel.value;

        if (gameController.isGameCompleted.value) {
          // Show game completed dialog
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => GameCompletedDialog(
                score: gameController.score.value,
                totalChallenges: gameController.challenges.length,
                onLevelSelect: () {
                  gameController.resetGame();
                  Get.back();
                  Get.back();
                },
                onPlayAgain: () {
                  gameController.resetGame();
                  gameController.generateChallenges(5);
                  Get.back();
                },
              ),
            );
          });
        }

        if (currentChallenge == null || level == null) {
          return const Center(child: Text('No challenge available'));
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (gameController.currentChallengeIndex.value + 1) /
                    gameController.challenges.length,
                backgroundColor: Colors.grey[300],
                color: Colors.green,
              ),
              const SizedBox(height: 24),

              // Challenge question
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.blue,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'What is the number on the line?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${currentChallenge.targetNumber}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.pink,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Number line
              Expanded(
                child: NumberLine(
                  minValue: currentChallenge.minNumber,
                  maxValue: currentChallenge.maxNumber,
                  step: currentChallenge.step,
                  targetValue: currentChallenge.targetNumber,
                  onSelect: (int selectedNumber) {
                    gameController.checkAnswer(selectedNumber);
                  },
                ),
              ),

              // Feedback area
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 50,
                color: gameController.isCorrectAnswer.value
                    ? Colors.green
                    : Colors.transparent,
                child: gameController.isCorrectAnswer.value
                    ? const Center(
                        child: Text(
                          'Correct!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : Container(),
              ),

              // Check button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton(
                  onPressed: () {
                    // This button can be used for checking if needed
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Check Answer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
