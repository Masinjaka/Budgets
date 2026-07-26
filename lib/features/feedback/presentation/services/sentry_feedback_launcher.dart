import 'dart:async';

import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:feedback_sentry/feedback_sentry.dart';
import 'package:flutter/material.dart';

abstract final class SentryFeedbackLauncher {
  static const _drawerAnimationDuration = Duration(milliseconds: 250);

  static void show(
    BuildContext context, {
    VoidCallback? beforeShow,
  }) {
    beforeShow?.call();
    unawaited(
      Future<void>.delayed(_drawerAnimationDuration, () {
        if (!context.mounted) return;
        BetterFeedback.of(context).show(
          (feedback) => submit(context, feedback),
        );
      }),
    );
  }

  static Future<void> submit(
    BuildContext context,
    UserFeedback feedback, {
    OnFeedbackCallback? uploader,
  }) async {
    // The extension does not expose upload completion, while its uploader
    // does. Completion is required for the app's toast lifecycle.
    // ignore: invalid_use_of_visible_for_testing_member
    final upload = uploader ?? sendToSentry();
    try {
      await upload(feedback);
      if (context.mounted) {
        showSuccessToast(context, context.l10n.feedbackSent);
      }
    } catch (error) {
      if (context.mounted) showErrorToast(context, error);
    }
  }
}
