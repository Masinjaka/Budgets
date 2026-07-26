import 'package:budgets/features/settings/domain/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('an explicit selection is not overwritten by the startup load',
      () async {
    SharedPreferences.setMockInitialValues({
      'selectedTheme': ThemeOptions.light.name,
    });
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(themeProvider), ThemeMode.light);
    await container.read(themeProvider.notifier).setTheme(ThemeOptions.dark);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(themeProvider), ThemeMode.dark);
    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString('selectedTheme'),
      ThemeOptions.dark.name,
    );
  });
}
