import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/core/ui/app_button_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Dark colors
  static const Color backgroundDark = Color(0xFF08090A);
  static const Color secondaryDark = Color(0xFF141617);
  static const Color borderColorDark = Color(0xff303237);
  static const Color primaryGreen = Color(0xFF10B981);
  static const Color secondaryGreen = Color(0xff4C8352);
  static const Color dangerColor = Color(0xFFE57373);
  static const Color neutralSurface = Color(0xFFF3F3F3);
  static const Color textDark = Color(0xffEFEFEF);
  static const Color mutedTextDark = Color(0xFFB5B7B8);
  static const Color raisedSurfaceDark = Color(0xFF1D2022);

  // Light colors
  static const Color backgroundLight = Color(0xFFFEFEFE);
  static const Color secondaryLight = neutralSurface;
  static const Color raisedSurfaceLight = Colors.white;
  static const Color textLight = Color(0xFF333333);
  static const Color mutedTextLight = Color(0xFF606060);
  static const Color borderColorLight = Color(0xFFD8D8D8);
  static const Color interactiveTextColor = Colors.black;

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: backgroundLight,
    cardColor: secondaryLight,
    primaryColor: primaryGreen,
    fontFamily: GoogleFonts.nunito().fontFamily,
    textTheme: GoogleFonts.nunitoTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(
          color: textLight,
          fontSize: AppTypography.body,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(
          color: textLight,
          fontSize: AppTypography.body,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textLight,
          fontSize: AppTypography.headline,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: textLight,
          fontSize: AppTypography.title,
          fontWeight: FontWeight.w700,
        ),
        titleSmall: TextStyle(
          color: textLight,
          fontSize: AppTypography.body,
          fontWeight: FontWeight.w600,
        ),
        bodySmall: TextStyle(
          color: textLight,
          fontSize: AppTypography.supporting,
          fontWeight: FontWeight.w600,
        ),
        labelLarge: TextStyle(
          fontSize: AppTypography.body,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundLight,
      elevation: 0,
      iconTheme: IconThemeData(color: textLight),
    ),
    dialogTheme: const DialogThemeData(backgroundColor: backgroundLight),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: backgroundLight,
    ),
    tabBarTheme: const TabBarThemeData(
      indicatorColor: backgroundDark,
      labelColor: backgroundLight,
      unselectedLabelColor: textLight,
    ),
    elevatedButtonTheme: AppButtonTheme.elevated(Brightness.light),
    textButtonTheme: AppButtonTheme.text(Brightness.light),
    outlinedButtonTheme: AppButtonTheme.outlined(Brightness.light),
    filledButtonTheme: AppButtonTheme.filled(Brightness.light),
    colorScheme: const ColorScheme.light(
      primary: primaryGreen,
      onPrimary: interactiveTextColor,
      secondary: secondaryGreen,
      error: dangerColor,
      surface: secondaryLight,
      surfaceDim: backgroundLight,
      surfaceContainer: secondaryLight,
      surfaceContainerLowest: raisedSurfaceLight,
      onSurface: textLight,
      onSurfaceVariant: mutedTextLight,
      outline: borderColorLight,
      inverseSurface: Colors.black,
      onInverseSurface: raisedSurfaceLight,
      tertiary: borderColorDark,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    cardColor: secondaryDark,
    primaryColor: primaryGreen,
    fontFamily: GoogleFonts.nunito().fontFamily,
    textTheme: GoogleFonts.nunitoTextTheme(
      const TextTheme(
        bodyLarge: TextStyle(
          color: textDark,
          fontSize: AppTypography.body,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: TextStyle(
          color: textDark,
          fontSize: AppTypography.body,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textDark,
          fontSize: AppTypography.headline,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: textDark,
          fontSize: AppTypography.title,
          fontWeight: FontWeight.w700,
        ),
        titleSmall: TextStyle(
          color: textDark,
          fontSize: AppTypography.body,
          fontWeight: FontWeight.w600,
        ),
        bodySmall: TextStyle(
          color: textDark,
          fontSize: AppTypography.supporting,
          fontWeight: FontWeight.w600,
        ),
        labelLarge: TextStyle(
          fontSize: AppTypography.body,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: backgroundDark,
      elevation: 0,
      iconTheme: IconThemeData(color: textDark),
    ),
    dialogTheme: const DialogThemeData(backgroundColor: secondaryDark),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: secondaryDark,
    ),
    tabBarTheme: const TabBarThemeData(
      indicatorColor: backgroundLight,
      labelColor: backgroundDark,
      unselectedLabelColor: textDark,
    ),
    elevatedButtonTheme: AppButtonTheme.elevated(Brightness.dark),
    textButtonTheme: AppButtonTheme.text(Brightness.dark),
    outlinedButtonTheme: AppButtonTheme.outlined(Brightness.dark),
    filledButtonTheme: AppButtonTheme.filled(Brightness.dark),
    colorScheme: const ColorScheme.dark(
      primary: primaryGreen,
      onPrimary: interactiveTextColor,
      secondary: secondaryGreen,
      error: dangerColor,
      surface: secondaryDark,
      surfaceDim: backgroundDark,
      surfaceContainer: secondaryDark,
      surfaceContainerLowest: raisedSurfaceDark,
      onSurface: textDark,
      onSurfaceVariant: mutedTextDark,
      outline: borderColorDark,
      inverseSurface: Colors.white,
      onInverseSurface: Colors.black,
      tertiary: Color.fromARGB(255, 126, 126, 126),
    ),
  );
}
