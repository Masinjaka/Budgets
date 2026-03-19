import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Dark colors
  static const Color backgroundDark = Color(0xFF08090A);
  static const Color secondaryDark = Color(0xFF141617);
  static const Color borderColorDark = Color(0xff303237);
  static const Color primaryGreen = Color(0xFF63B173);
  static const Color secondaryGreen = Color(0xff4C8352);

  //Text Colors
  static const Color textDark = Color(0xffEFEFEF);

  // Light colors
  static const Color backgroundLight = Color(0xFFF4F7F5);
  static const Color secondaryLight = Color(0xFFE8EBE9);
  static const Color textLight = Color(0xff333333);


  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundLight,
    cardColor: secondaryLight,
    primaryColor: primaryGreen,
    fontFamily: GoogleFonts.outfit().fontFamily,
    textTheme: GoogleFonts.outfitTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(color: textLight),
        bodyMedium: TextStyle(color: textLight),
        titleLarge: TextStyle(color: textLight),
        titleMedium: TextStyle(color: textLight),
        titleSmall: TextStyle(color: textLight),
        bodySmall: TextStyle(color: textLight),
        labelMedium: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundLight,
      elevation: 0,
      iconTheme: IconThemeData(color: textLight),
    ),
    tabBarTheme: const TabBarThemeData(
      indicatorColor: backgroundDark,
      labelColor: backgroundLight,
      unselectedLabelColor: textLight,
    ),
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      secondary: secondaryGreen,
      surface: secondaryLight,
      surfaceDim: backgroundLight,
      inverseSurface: secondaryDark,
      tertiary: borderColorDark,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    cardColor: secondaryDark,
    primaryColor: primaryGreen,
    fontFamily: GoogleFonts.outfit().fontFamily,
    textTheme: GoogleFonts.outfitTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(color: textDark),
        bodyMedium: TextStyle(color: textDark),
        titleLarge: TextStyle(color: textDark),
        titleMedium: TextStyle(color: textDark),
        titleSmall: TextStyle(color: textDark),
        bodySmall: TextStyle(
          color: textDark,
        ),
        labelMedium: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundDark,
      elevation: 0,
      iconTheme: IconThemeData(color: textDark),
    ),
    tabBarTheme: const TabBarThemeData(
      indicatorColor: backgroundLight,
      labelColor: backgroundDark,
      unselectedLabelColor: textDark,
    ),
    colorScheme: const ColorScheme.dark(
      primary: primaryGreen,
      secondary: secondaryGreen,
      surface: secondaryDark,
      surfaceDim: backgroundDark,
      inverseSurface: secondaryLight,
      tertiary: Color.fromARGB(255, 126, 126, 126),
    ),
  );
}
