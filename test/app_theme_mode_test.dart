import 'package:budgets/core/navigation/app_navigation.dart';
import 'package:budgets/core/theme.dart';
import 'package:budgets/features/onboarding/presentation/pages/getting_started_page.dart';
import 'package:budgets/features/settings/domain/providers/theme_provider.dart';
import 'package:budgets/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('applies the saved dark theme to the app', (tester) async {
    expect(
      AppTheme.lightTheme.colorScheme.surface,
      AppTheme.secondaryLight,
    );
    expect(
      AppTheme.darkTheme.colorScheme.surface,
      AppTheme.secondaryDark,
    );
    expect(
      AppTheme.lightTheme.colorScheme.surfaceContainer,
      AppTheme.secondaryLight,
    );
    expect(
      AppTheme.darkTheme.colorScheme.surfaceContainer,
      AppTheme.secondaryDark,
    );
    final navigation = AppNavigation(
      isSignedIn: () => false,
      authChanges: const Stream<Object?>.empty(),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [themeProvider.overrideWithValue(ThemeMode.dark)],
        child: MyApp(navigation: navigation),
      ),
    );

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(app.darkTheme, same(AppTheme.darkTheme));

    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('reacts when the user selects dark mode', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    final navigation = AppNavigation(
      isSignedIn: () => false,
      authChanges: const Stream<Object?>.empty(),
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MyApp(navigation: navigation),
      ),
    );

    await container.read(themeProvider.notifier).setTheme(ThemeOptions.dark);
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    expect(
      Theme.of(tester.element(find.byType(GettingStartedPage))).brightness,
      Brightness.dark,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
  });
}
