import 'package:flutter/material.dart';

class AppTheme {
  // Dark colors
  static const Color backgroundDark = Color(0xff0A0C10);
  static const Color secondaryDark = Color(0xff15171A);
  static const Color borderColorDark = Color(0xff303237);
  static const Color primaryGreen = Color(0xff10B981);
  static const Color secondaryGreen = Color(0xff4C8352);

  //Text Colors
  static const Color textDark = Color(0xffEFEFEF);

  // Light colors
  static const Color backgroundLight = Color(0xffFFFFFF);
  static const Color secondaryLight = Color(0xffE9E9E9);
  static const Color textLight = Color(0xff0A0C10);

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundLight,
    cardColor: secondaryLight,
    primaryColor: primaryGreen,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textLight),
      bodyMedium: TextStyle(color: textLight),
      titleLarge: TextStyle(color: textLight),
      titleMedium: TextStyle(color: textLight),
      titleSmall: TextStyle(color: textLight),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundLight,
      elevation: 0,
      iconTheme: IconThemeData(color: textLight),
    ),
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: secondaryGreen,
      surface: secondaryLight,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    cardColor: secondaryDark,
    primaryColor: primaryGreen,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textDark),
      bodyMedium: TextStyle(color: textDark),
      titleLarge: TextStyle(color: textDark),
      titleMedium: TextStyle(color: textDark),
      titleSmall: TextStyle(color: textDark),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundDark,
      elevation: 0,
      iconTheme: IconThemeData(color: textDark),
    ),
    colorScheme: const ColorScheme.dark(
      primary: primaryGreen,
      secondary: secondaryGreen,
      surface: secondaryDark,
    ),
  );
}
