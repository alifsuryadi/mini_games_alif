import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mini_games_alif/domain/entities/gcf_level.dart';
import 'package:mini_games_alif/presentation/controllers/gcf_challenge_controller.dart';
import 'package:mini_games_alif/presentation/widgets/gcf_number_line.dart';

class GCFChallengePage extends StatelessWidget {
  const GCFChallengePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GCFChallengeController());

    return Scaffold(
      backgroundColor: const Color(0xFFE8EAF6),
      appBar: AppBar(
        title: Obx(() =>
            Text(controller.currentLevel.value?.title ?? 'GCF Challenge')),
        backgroundColor: const Color(0xFF3F51B5),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Level selector
              Obx(() => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: DropdownButton<GCFLevel>(
                      value: controller.currentLevel.value,
                      isExpanded: true,
                      underline: const SizedBox(),
                      onChanged: (GCFLevel? level) {
                        if (level != null) {
                          controller.setLevel(level);
                        }
                      },
                      items: controller.levels.map((GCFLevel level) {
                        return DropdownMenuItem<GCFLevel>(
                          value: level,
                          child: Text(level.title),
                        );
                      }).toList(),
                    ),
                  )),

              const SizedBox(height: 20),

              // GCF Challenge UI
              Obx(() => GCFNumberLine(
                    value1: controller.value1.value,
                    value2: controller.value2.value,
                    minRange: controller.minRange.value,
                    maxRange: controller.maxRange.value,
                    rangeWidth: controller.rangeWidth.value,
                    onAnswerSubmitted: (int answer) {
                      controller.checkAnswer(answer);
                    },
                  )),

              const SizedBox(height: 20),

              // Display second value
              Obx(() => Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Second value: ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${controller.value2.value}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF4081),
                          ),
                        ),
                      ],
                    ),
                  )),

              const SizedBox(height: 20),

              // Feedback area
              Obx(() => AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: controller.isCorrect.value ||
                            controller.selectedAnswer.value > 0
                        ? 80
                        : 0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: controller.isCorrect.value
                          ? Colors.green
                          : Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: controller.selectedAnswer.value == 0
                          ? const SizedBox()
                          : Text(
                              controller.isCorrect.value
                                  ? 'Correct! The GCF is ${controller.correctAnswer.value}'
                                  : 'Try again. Your answer: ${controller.selectedAnswer.value}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  )),

              const Spacer(),

              // Next challenge button
              ElevatedButton.icon(
                onPressed: () {
                  controller.generateChallenge();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('New Challenge'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
