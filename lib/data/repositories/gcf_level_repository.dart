import 'package:mini_games_alif/domain/entities/gcf_level.dart';

class GCFLevelRepository {
  List<GCFLevel> getLevels() {
    return [
      GCFLevel(
        id: 1,
        title: 'Level 1: Basic',
        description: 'Find GCF of numbers between 1-20',
        minRange: 1,
        maxRange: 20,
        rangeWidth: 5,
      ),
      GCFLevel(
        id: 2,
        title: 'Level 2: Intermediate',
        description: 'Find GCF of numbers between 10-50',
        minRange: 10,
        maxRange: 50,
        rangeWidth: 10,
      ),
      GCFLevel(
        id: 3,
        title: 'Level 3: Advanced',
        description: 'Find GCF of numbers between 20-100',
        minRange: 20,
        maxRange: 100,
        rangeWidth: 20,
      ),
      GCFLevel(
        id: 4,
        title: 'Level 4: Expert',
        description: 'Find GCF of numbers between 100-1000',
        minRange: 100,
        maxRange: 1000,
        rangeWidth: 100,
      ),
      GCFLevel(
        id: 5,
        title: 'Level 5: Master',
        description: 'Find GCF of numbers between 1000-2000',
        minRange: 1000,
        maxRange: 2000,
        rangeWidth: 20,
      ),
    ];
  }
}
