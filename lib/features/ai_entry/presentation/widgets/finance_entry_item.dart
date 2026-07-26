import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/core/currency/currency_state.dart';
import 'package:budgets/features/ai_entry/domain/models/finance_entry.dart';
import 'package:budgets/features/ai_entry/presentation/widgets/finance_entry_amount_badge.dart';
import 'package:budgets/features/ai_entry/presentation/widgets/finance_entry_icon.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/material.dart';

class FinanceEntryItem extends StatelessWidget {
  const FinanceEntryItem({
    required this.entry,
    this.onTap,
    this.currencyState,
    super.key,
  });

  static const height = 76.0;

  final FinanceEntry entry;
  final VoidCallback? onTap;
  final CurrencyState? currencyState;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FinanceEntryIcon(
                emoji: entry.emoji,
                iconKey: entry.iconKey,
              ),
              const SizedBox(width: 17),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: AppTypography.body,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            entry.categoryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontSize: AppTypography.supporting,
                            ),
                          ),
                        ),
                        if (entry.envelopeName case final envelopeName?) ...[
                          const SizedBox(width: 5),
                          Tooltip(
                            key: Key('finance-entry-envelope-${entry.id}'),
                            message:
                                context.l10n.takenFromEnvelope(envelopeName),
                            child: Icon(
                              Icons.mail_outline_rounded,
                              size: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FinanceEntryAmountBadge(
                entry: entry,
                currencyState: currencyState,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
