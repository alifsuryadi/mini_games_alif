import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mini_games_alif/core/routes/app_routes.dart';
import 'package:mini_games_alif/core/styles/app_colors.dart';
import 'package:mini_games_alif/core/styles/app_sizes.dart';
import 'package:mini_games_alif/core/styles/card_colors/card_colors.dart';
import 'package:mini_games_alif/data/repositories/game_repository.dart';
import 'package:mini_games_alif/domain/models/level_model.dart';
import 'package:mini_games_alif/presentation/widgets/card_widget.dart';

class LevelSelectPage extends StatefulWidget {
  const LevelSelectPage({Key? key}) : super(key: key);

  @override
  State<LevelSelectPage> createState() => _LevelSelectPageState();
}

class _LevelSelectPageState extends State<LevelSelectPage> {
  final GameRepository _repository = GameRepository();
  List<LevelModel> _levels = [];
  String _gameName = '';
  Map<int, List<LevelModel>> _levelsBySubsection = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLevels();
    });
  }

  void _loadLevels() {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final gameId = args['gameId'] as int;

    final levels = _repository
        .getAllLevels()
        .where((level) => level.gameId == gameId)
        .toList();

    // Group levels by subsection for organized display
    Map<int, List<LevelModel>> levelsBySubsection = {};
    for (var level in levels) {
      final subSectionId = level.subSectionId ?? 0;
      if (!levelsBySubsection.containsKey(subSectionId)) {
        levelsBySubsection[subSectionId] = [];
      }
      levelsBySubsection[subSectionId]!.add(level);
    }

    final games =
        _repository.getGames().where((game) => game.gameId == gameId).toList();

    setState(() {
      _levels = levels;
      _levelsBySubsection = levelsBySubsection;
      _gameName = games.isNotEmpty ? games.first.gameName : 'Game';
    });
  }

  @override
  Widget build(BuildContext context) {
    AppSizes.init(context, 1.0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          _gameName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: _levels.isEmpty
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemCount: _levelsBySubsection.length,
                  itemBuilder: (context, index) {
                    final subsectionId =
                        _levelsBySubsection.keys.toList()[index];
                    final subsectionLevels = _levelsBySubsection[subsectionId]!;

                    if (subsectionLevels.isEmpty)
                      return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: Text(
                            subsectionLevels.first.subSectionName,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          subsectionLevels.first.subSectionDescription,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1.0,
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 12.h,
                          ),
                          itemCount: subsectionLevels.length,
                          itemBuilder: (context, levelIndex) {
                            final level = subsectionLevels[levelIndex];
                            return _buildLevelCard(level);
                          },
                        ),
                        SizedBox(height: 24.h),
                        Divider(thickness: 1.h),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(LevelModel level) {
    // A level is unlocked if it's the first level or the previous level is completed
    final bool isFirstLevel = level.levelId == 1;
    final bool isPreviousCompleted = _levels
        .where((l) => l.levelId == level.levelId - 1)
        .any((l) => l.isCompleted);
    final bool isUnlocked =
        isFirstLevel || isPreviousCompleted || level.isUnlocked;

    return GestureDetector(
      onTap: isUnlocked
          ? () {
              Navigator.pushNamed(
                context,
                AppRoutes.game,
                arguments: {'levelId': level.levelId},
              ).then((_) {
                // Refresh levels when returning from game screen
                _loadLevels();
              });
            }
          : null,
      child: CardWidget(
        isMoved: false,
        isHovered: false,
        cardColor: isUnlocked ? CardColors.blue : CardColors.gray,
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    level.levelId.toString(),
                    style: TextStyle(
                      color: isUnlocked
                          ? AppColors.textPrimary
                          : AppColors.textLight,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  if (!isUnlocked)
                    Icon(
                      Icons.lock,
                      color: AppColors.textLight,
                      size: 20.sp,
                    )
                  else
                    Text(
                      level.levelDescription,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isUnlocked
                            ? AppColors.textSecondary
                            : AppColors.textLight,
                        fontSize: 10.sp,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (level.isCompleted)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          return Icon(
                            index < level.stars
                                ? Icons.star
                                : Icons.star_border,
                            color: index < level.stars
                                ? AppColors.numberYellow
                                : Colors.grey,
                            size: 16.sp,
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
            if (level.isCompleted)
              Positioned(
                top: 8.h,
                right: 8.w,
                child: Container(
                  width: 18.w,
                  height: 18.w,
                  decoration: const BoxDecoration(
                    color: AppColors.correctFeedback,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12.sp,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
