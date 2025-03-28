import 'package:mini_games_alif/domain/entities/section.dart';
import 'package:mini_games_alif/data/repositories/level_repository.dart';

class GetGameSectionsUseCase {
  final LevelRepository levelRepository;

  GetGameSectionsUseCase(this.levelRepository);

  List<Section> execute() {
    return levelRepository.getGameSections();
  }
}
