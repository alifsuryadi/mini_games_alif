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
    final games =
        _repository.getGames().where((game) => game.gameId == gameId).toList();

    setState(() {
      _levels = levels;
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select a Level',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: _levels.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.0,
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 12.h,
                        ),
                        itemCount: _levels.length,
                        itemBuilder: (context, index) {
                          final level = _levels[index];
                          return _buildLevelCard(level);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(LevelModel level) {
    final bool isUnlocked =
        level.levelId == 1 || _levels[level.levelId - 2].isCompleted;

    return GestureDetector(
      onTap: isUnlocked
          ? () {
              Navigator.pushNamed(
                context,
                AppRoutes.game,
                arguments: {'levelId': level.levelId},
              );
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
                  if (level.isCompleted)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return Icon(
                          index < level.stars ? Icons.star : Icons.star_border,
                          color: index < level.stars
                              ? AppColors.numberYellow
                              : Colors.grey,
                          size: 16.sp,
                        );
                      }),
                    ),
                ],
              ),
            ),
            if (!isUnlocked)
              Center(
                child: Icon(
                  Icons.lock,
                  color: AppColors.textLight,
                  size: 24.sp,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
