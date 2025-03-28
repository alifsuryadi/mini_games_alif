import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: const Color(0xFF3F51B5),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: const Color(0xFF3F51B5),
      secondary: const Color(0xFF03A9F4),
      background: const Color(0xFFF5F5F5),
    ),
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
      displayMedium: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
      displaySmall: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
      bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF333333)),
      bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF333333)),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: Color(0xFF4CAF50),
      textTheme: ButtonTextTheme.primary,
    ),
  );
}
