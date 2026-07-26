import 'package:budgets/core/ui/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:budgets/l10n/app_localizations_context.dart';

class AiRequestQuotaLabel extends StatelessWidget {
  const AiRequestQuotaLabel({
    required this.remaining,
    this.unlimited = false,
    super.key,
  });

  final int? remaining;
  final bool unlimited;

  @override
  Widget build(BuildContext context) {
    if (unlimited) return const SizedBox.shrink();
    final count = remaining;
    return SizedBox(
      height: 24,
      child: count == null
          ? const SizedBox.shrink()
          : Center(
              child: _remainingQuotaText(context, count),
            ),
    );
  }

  Widget _remainingQuotaText(BuildContext context, int count) {
    final countText = '$count';
    final message = context.l10n.aiRequestsRemaining(count);
    final countIndex = message.indexOf(countText);
    if (countIndex < 0) {
      return Text(message, key: const Key('ai-request-quota-label'));
    }
    return Text.rich(
      TextSpan(
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: AppTypography.supporting,
          fontWeight: FontWeight.w600,
        ),
        children: [
          TextSpan(text: message.substring(0, countIndex)),
          TextSpan(
            text: countText,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          TextSpan(text: message.substring(countIndex + countText.length)),
        ],
      ),
      key: const Key('ai-request-quota-label'),
    );
  }
}
