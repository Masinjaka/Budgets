import 'package:budgets/core/ui/app_control_metrics.dart';
import 'package:budgets/core/ui/app_typography.dart';
import 'package:flutter/material.dart';

abstract final class AppButtonTheme {
  static ElevatedButtonThemeData elevated(Brightness brightness) =>
      ElevatedButtonThemeData(style: _filled(brightness));

  static FilledButtonThemeData filled(Brightness brightness) =>
      FilledButtonThemeData(style: _filled(brightness));

  static OutlinedButtonThemeData outlined(Brightness brightness) =>
      OutlinedButtonThemeData(
        style: _base(brightness).copyWith(
          side: WidgetStatePropertyAll(
            BorderSide(color: _foreground(brightness)),
          ),
          backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      );

  static TextButtonThemeData text(Brightness brightness) => TextButtonThemeData(
        style: _base(brightness),
      );

  static ButtonStyle _filled(Brightness brightness) =>
      _base(brightness).copyWith(
        backgroundColor: WidgetStatePropertyAll(_foreground(brightness)),
        foregroundColor: WidgetStatePropertyAll(_background(brightness)),
      );

  static ButtonStyle _base(Brightness brightness) => ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(
          Size(0, AppControlMetrics.height),
        ),
        foregroundColor: WidgetStatePropertyAll(_foreground(brightness)),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(
            fontSize: AppTypography.body,
            fontWeight: FontWeight.w800,
          ),
        ),
        shape: const WidgetStatePropertyAll(StadiumBorder()),
      );

  static Color _foreground(Brightness brightness) =>
      brightness == Brightness.dark ? Colors.white : Colors.black;

  static Color _background(Brightness brightness) =>
      brightness == Brightness.dark ? Colors.black : Colors.white;
}
