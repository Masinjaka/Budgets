import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Always use dark mode
final appThemeProvider = StateProvider((ref) {
    return ThemeMode.dark;
},);

// Always return dark brightness
final globalThemeProvider = StateProvider<Brightness>((ref) {
  return Brightness.dark;
},);