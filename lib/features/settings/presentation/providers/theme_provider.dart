import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

const String _themePrefsKey = 'selectedTheme';

enum ThemeOptions { system, light, dark }

@Riverpod(keepAlive: true)
class ThemeNotifier extends _$ThemeNotifier {
  @override
  ThemeMode build() {
    _loadTheme();
    return ThemeMode.light;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_themePrefsKey);
    if (themeName != null) {
      final theme = ThemeOptions.values.firstWhere(
        (e) => e.toString() == themeName,
        orElse: () => ThemeOptions.light,
      );
      _setTheme(theme);
    } else {
      _setTheme(ThemeOptions.light);
    }
  }

  void _setTheme(ThemeOptions theme) {
    switch (theme) {
      case ThemeOptions.system:
        state = ThemeMode.system;
        break;
      case ThemeOptions.light:
        state = ThemeMode.light;
        break;
      case ThemeOptions.dark:
        state = ThemeMode.dark;
        break;
    }
  }

  Future<void> setTheme(ThemeOptions theme) async {
    _setTheme(theme);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePrefsKey, theme.toString());
  }
}
