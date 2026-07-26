import 'package:budgets/features/settings/domain/providers/locale_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persists the selected French locale', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(localeProvider.notifier).setLocale(const Locale('fr'));

    expect(container.read(localeProvider), const Locale('fr'));
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('selected_locale'), 'fr');
  });

  test('restores a persisted supported locale', () async {
    SharedPreferences.setMockInitialValues({'selected_locale': 'fr'});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(localeProvider);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(localeProvider), const Locale('fr'));
  });
}
