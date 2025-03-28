// lib/presentation/widgets/game_completed_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mini_games_alif/presentation/controllers/game_controller.dart';

class GameCompletedDialog extends StatelessWidget {
  final int score;
  final int totalChallenges;
  final VoidCallback onLevelSelect;
  final VoidCallback onPlayAgain;

  const GameCompletedDialog({
    super.key,
    required this.score,
    required this.totalChallenges,
    required this.onLevelSelect,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Level Completed!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your Score: $score/$totalChallenges',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: onLevelSelect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('Level Select'),
                ),
                ElevatedButton(
                  onPressed: onPlayAgain,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Play Again'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
