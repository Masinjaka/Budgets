import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/features/ai_entry/domain/models/ai_entry_result.dart';
import 'package:flutter/material.dart';

class AiEntryResultFeedback {
  const AiEntryResultFeedback._();

  static void show(BuildContext context, AiEntryResult result) {
    final count = result.entries.length;
    final quota = result.unlimited
        ? 'Unlimited AI requests with Drala Plus.'
        : '${result.remaining} AI requests left today.';
    showAppToast(
      context,
      count == 0
          ? result.message
          : '$count ${count == 1 ? 'entry' : 'entries'} added. $quota',
      type: count == 0 ? AppToastType.info : AppToastType.success,
    );
    if (result.notice case final String notice) showInfoToast(context, notice);
  }
}
