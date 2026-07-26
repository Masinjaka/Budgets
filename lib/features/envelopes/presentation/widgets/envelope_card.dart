import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/core/ui/privacy_text.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:budgets/features/envelopes/domain/models/envelope.dart';
import 'package:budgets/features/envelopes/presentation/widgets/envelope_overspend_warning.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/material.dart';

class EnvelopeCard extends StatelessWidget {
  const EnvelopeCard({
    required this.envelope,
    required this.onDelete,
    this.displayCurrency,
    super.key,
  });

  final Envelope envelope;
  final VoidCallback onDelete;
  final CurrencyState? displayCurrency;

  @override
  Widget build(BuildContext context) {
    final progress = envelope.progress.clamp(0.0, 1.0);
    final accent = envelope.isExceeded
        ? const Color(0xFFD84A3A)
        : Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 16, 14, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                ),
                child:
                    Text(envelope.emoji, style: const TextStyle(fontSize: 19)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      envelope.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      envelope.categoryName,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz_rounded, size: 21),
                onSelected: (_) => onDelete(),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(context.l10n.deleteEnvelope),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: progress,
              backgroundColor:
                  Theme.of(context).colorScheme.outline.withValues(alpha: .28),
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
          const SizedBox(height: 10),
          if (envelope.isExceeded) ...[
            EnvelopeOverspendWarning(
              envelope: envelope,
              displayCurrency: displayCurrency,
            ),
            const SizedBox(height: 10),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: PrivacyText(
                  context.l10n.amountSpent(
                    formatAmountWithCurrency(
                      _convert(envelope.spent),
                      displayCurrency?.code ?? envelope.currencyCode,
                      preserveFraction: true,
                    ),
                  ),
                  hiddenText: context.l10n.amountSpent('***'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: accent,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Flexible(
                child: PrivacyText(
                  context.l10n.ofAmount(
                    formatAmountWithCurrency(
                      _convert(envelope.amount),
                      displayCurrency?.code ?? envelope.currencyCode,
                      preserveFraction: true,
                    ),
                  ),
                  hiddenText: context.l10n.ofAmount('***'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  num _convert(num amount) =>
      displayCurrency?.convertToSelected(
        amount,
        envelope.currencyCode,
      ) ??
      amount;
}
