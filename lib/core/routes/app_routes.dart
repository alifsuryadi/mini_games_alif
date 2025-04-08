import 'package:flutter/material.dart';
import 'package:mini_games_alif/presentation/pages/game_page.dart';
import 'package:mini_games_alif/presentation/pages/home_page.dart';
import 'package:mini_games_alif/presentation/pages/level_select_page.dart';
import 'package:mini_games_alif/presentation/pages/splash_page.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/home';
  static const String levelSelect = '/level_select';
  static const String game = '/game';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashPage(),
    home: (context) => const HomePage(),
    levelSelect: (context) => const LevelSelectPage(),
    game: (context) => const GamePage(),
  };
}
