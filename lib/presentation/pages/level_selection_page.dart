import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mini_games_alif/domain/entities/level.dart';
import 'package:mini_games_alif/presentation/controllers/game_controller.dart';
import 'package:mini_games_alif/presentation/pages/game_page.dart';

class LevelSelectionPage extends StatelessWidget {
  const LevelSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GameController gameController = Get.find<GameController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Level'),
        backgroundColor: const Color(0xFF3F51B5),
      ),
      body: Obx(() {
        final currentSection = gameController.currentSection.value;

        if (currentSection == null) {
          return const Center(child: Text('No sections available'));
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                currentSection.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: currentSection.levels.length,
                itemBuilder: (context, index) {
                  final level = currentSection.levels[index];
                  return _buildLevelCard(context, level, gameController);
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLevelCard(
      BuildContext context, Level level, GameController gameController) {
    return GestureDetector(
      onTap: () {
        gameController.selectLevel(level);
        Get.to(() => const GamePage());
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star,
              size: 50,
              color: const Color(0xFF3F51B5),
            ),
            const SizedBox(height: 8),
            Text(
              'Level ${level.id}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                level.description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
