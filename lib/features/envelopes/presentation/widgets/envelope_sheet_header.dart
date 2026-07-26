import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EnvelopeSheetHeader extends StatelessWidget {
  const EnvelopeSheetHeader({required this.month, super.key});

  final DateTime month;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.newEnvelope,
          style: const TextStyle(
            fontSize: AppTypography.headline,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          DateFormat.yMMMM(locale).format(month),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: AppTypography.supporting,
          ),
        ),
      ],
    );
  }
}
