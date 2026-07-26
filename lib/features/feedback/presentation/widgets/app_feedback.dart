import 'package:budgets/core/theme.dart';
import 'package:budgets/features/feedback/presentation/widgets/app_feedback_form.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';

class AppFeedback extends StatelessWidget {
  const AppFeedback({
    required this.child,
    required this.themeMode,
    super.key,
  });

  final Widget child;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    return BetterFeedback(
      feedbackBuilder: (context, onSubmit, scrollController) => AppFeedbackForm(
        onSubmit: onSubmit,
        scrollController: scrollController,
      ),
      themeMode: themeMode,
      theme: _feedbackTheme(AppTheme.lightTheme),
      darkTheme: _feedbackTheme(AppTheme.darkTheme),
      child: child,
    );
  }

  FeedbackThemeData _feedbackTheme(ThemeData theme) {
    final sheetColor =
        theme.bottomSheetTheme.backgroundColor ?? theme.scaffoldBackgroundColor;
    final textStyle = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.onSurface,
    );
    return FeedbackThemeData(
      brightness: theme.brightness,
      background: Colors.black54,
      feedbackSheetColor: sheetColor,
      feedbackSheetHeight: .38,
      activeFeedbackModeColor: AppTheme.primaryGreen,
      drawColors: const [
        AppTheme.dangerColor,
        AppTheme.primaryGreen,
        Colors.blue,
        Colors.black,
      ],
      bottomSheetDescriptionStyle: textStyle,
      bottomSheetTextInputStyle: textStyle,
      colorScheme: theme.colorScheme.copyWith(
        primary: AppTheme.primaryGreen,
        onPrimary: AppTheme.interactiveTextColor,
        surface: sheetColor,
        onSurface: theme.colorScheme.onSurface,
      ),
    );
  }
}
