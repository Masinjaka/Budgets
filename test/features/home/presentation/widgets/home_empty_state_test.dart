import 'package:budgets/core/theme.dart';
import 'package:budgets/features/home/presentation/widgets/home_empty_prompt_card.dart';
import 'package:budgets/features/home/presentation/widgets/home_empty_state.dart';
import 'package:budgets/l10n/generated/app_localizations.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

void main() {
  testWidgets('lets a returning user swipe through three prompts',
      (tester) async {
    await tester.pumpWidget(_app(isFirstEntryExperience: false));

    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.byType(HomeEmptyPromptCard), findsNWidgets(3));
    expect(find.text('💰'), findsOneWidget);
    expect(find.text('🛒'), findsOneWidget);
    expect(find.text('🔄'), findsOneWidget);
    expect(find.byKey(const Key('first-entry-prompt')), findsNothing);
    expect(find.byKey(const Key('home-prompt-left-fade')), findsOneWidget);
    expect(find.byKey(const Key('home-prompt-right-fade')), findsOneWidget);
    final centerHeight = tester
        .getSize(
          find.ancestor(
            of: find.text('💰'),
            matching: find.byType(HomeEmptyPromptCard),
          ),
        )
        .height;
    final sideHeight = tester
        .getSize(
          find.ancestor(
            of: find.text('🛒'),
            matching: find.byType(HomeEmptyPromptCard),
          ),
        )
        .height;
    expect(centerHeight, greaterThan(sideHeight));
    final indicator = tester.widget<AnimatedSmoothIndicator>(
      find.byKey(const Key('home-prompt-indicator')),
    );
    expect(indicator.activeIndex, 0);

    await tester.drag(find.byType(CarouselSlider), const Offset(-280, 0));
    await tester.pumpAndSettle();

    final updatedIndicator = tester.widget<AnimatedSmoothIndicator>(
      find.byKey(const Key('home-prompt-indicator')),
    );
    expect(updatedIndicator.activeIndex, 1);
    expect(find.text('🛒'), findsOneWidget);

    await tester.drag(find.byType(CarouselSlider), const Offset(-280, 0));
    await tester.pumpAndSettle();

    final finalIndicator = tester.widget<AnimatedSmoothIndicator>(
      find.byKey(const Key('home-prompt-indicator')),
    );
    expect(finalIndicator.activeIndex, 2);
    expect(find.text('🔄'), findsOneWidget);

    await tester.drag(find.byType(CarouselSlider), const Offset(-280, 0));
    await tester.pumpAndSettle();

    final loopedIndicator = tester.widget<AnimatedSmoothIndicator>(
      find.byKey(const Key('home-prompt-indicator')),
    );
    expect(loopedIndicator.activeIndex, 0);
    expect(find.text('💰'), findsOneWidget);
  });

  testWidgets('automatically advances the returning-user carousel',
      (tester) async {
    await tester.pumpWidget(_app(isFirstEntryExperience: false));

    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 520));

    final indicator = tester.widget<AnimatedSmoothIndicator>(
      find.byKey(const Key('home-prompt-indicator')),
    );
    expect(indicator.activeIndex, 1);
  });

  testWidgets('shows only the income prompt for a new account', (tester) async {
    await tester.pumpWidget(_app(isFirstEntryExperience: true));

    expect(find.text('Welcome to Drala!'), findsOneWidget);
    expect(find.byType(HomeEmptyPromptCard), findsOneWidget);
    expect(find.byKey(const Key('first-entry-prompt')), findsOneWidget);
    expect(find.text('🛒'), findsNothing);
    expect(find.text('🔄'), findsNothing);
    expect(find.byType(CarouselSlider), findsNothing);
  });
}

Widget _app({required bool isFirstEntryExperience}) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SizedBox(
        width: 400,
        height: 650,
        child: HomeEmptyState(
          isFirstEntryExperience: isFirstEntryExperience,
        ),
      ),
    ),
  );
}
