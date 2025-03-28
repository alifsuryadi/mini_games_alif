// import 'package:flutter/material.dart';
// import 'presentation/number_line_screen.dart'; // Pastikan path ini sesuai dengan struktur folder yang Anda buat

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Number Line Game',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: NumberLineScreen(), // Menentukan tampilan utama aplikasi
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'presentation/pages/home_page.dart';
// import 'core/theme/app_theme.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'Number Line Game',
//       theme: AppTheme.lightTheme,
//       home: const HomePage(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mini_games_alif/core/theme/app_theme.dart';
import 'package:mini_games_alif/presentation/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Number Line Game',
      theme: AppTheme.lightTheme,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
