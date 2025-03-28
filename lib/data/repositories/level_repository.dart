import 'package:mini_games_alif/domain/entities/level.dart';
import 'package:mini_games_alif/domain/entities/section.dart';
import 'package:mini_games_alif/domain/entities/game_challenge.dart';

class LevelRepository {
  // Get all game sections with levels
  List<Section> getGameSections() {
    return [
      Section(
        id: 1,
        title: 'Numbers',
        description:
            'Solve number placement challenges by positioning whole numbers correctly to learn the concept of numerical order.',
        icon: 'section_icon',
        levels: [
          Level(
            id: 1,
            title: 'Number range: 0 to 20',
            description: '0 to 10 by steps of 1',
            instructions:
                'Locate and choose the right number on the number line to solve each challenge.',
            startNumber: 0,
            endNumber: 10,
            step: 1,
            icon: 'nb_01',
          ),
          Level(
            id: 2,
            title: 'Number range: 0 to 20',
            description: '10 to 20 by steps of 1',
            instructions:
                'Locate and choose the right number on the number line to solve each challenge.',
            startNumber: 10,
            endNumber: 20,
            step: 1,
            icon: 'nb_02',
          ),
          Level(
            id: 3,
            title: 'Number range: 0 to 20',
            description: '0 to 20 by steps of 2',
            instructions:
                'Locate and choose the right number on the number line to solve each challenge.',
            startNumber: 0,
            endNumber: 20,
            step: 2,
            icon: 'nb_03',
          ),
          Level(
            id: 4,
            title: 'Number range: 0 to 20',
            description: '0 to 18 by steps of 3',
            instructions:
                'Locate and choose the right number on the number line to solve each challenge.',
            startNumber: 0,
            endNumber: 18,
            step: 3,
            icon: 'nb_04',
          ),
          Level(
            id: 5,
            title: 'Number range: 0 to 50',
            description: '20 to 30 by steps of 1',
            instructions:
                'Locate and choose the right number on the number line to solve each challenge.',
            startNumber: 20,
            endNumber: 30,
            step: 1,
            icon: 'nb_50_01',
          ),
        ],
      ),
    ];
  }

// Generate game challenges for a specific level
  List<GameChallenge> generateChallenges(Level level, int count) {
    List<GameChallenge> challenges = [];
    List<int> possibleNumbers = [];

    for (int i = level.startNumber; i <= level.endNumber; i += level.step) {
      possibleNumbers.add(i);
    }

    // Shuffle the numbers to get random challenges
    possibleNumbers.shuffle();

    // Take the required number of challenges
    for (int i = 0; i < count && i < possibleNumbers.length; i++) {
      challenges.add(
        GameChallenge(
          targetNumber: possibleNumbers[i],
          minNumber: level.startNumber,
          maxNumber: level.endNumber,
          step: level.step,
        ),
      );
    }

    return challenges;
  }
}
