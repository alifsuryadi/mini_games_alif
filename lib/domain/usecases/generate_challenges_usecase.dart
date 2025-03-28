import 'package:mini_games_alif/domain/entities/level.dart';
import 'package:mini_games_alif/domain/entities/game_challenge.dart';
import 'package:mini_games_alif/data/repositories/level_repository.dart';

class GenerateChallengesUseCase {
  final LevelRepository levelRepository;

  GenerateChallengesUseCase(this.levelRepository);

  List<GameChallenge> execute(Level level, int count) {
    return levelRepository.generateChallenges(level, count);
  }
}
