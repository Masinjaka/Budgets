import 'package:budgets/features/notifications/domain/models/finance_notification.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FinanceNotificationListItem extends StatelessWidget {
  const FinanceNotificationListItem({
    required this.notification,
    required this.onTap,
    super.key,
  });

  final FinanceNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Material(
      color:
          notification.isRead ? colors.surface : colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        key: Key('finance-notification-${notification.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_rounded,
                color: Color(0xFFD84A3A),
                size: 25,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.envelopeBudgetExceeded(
                        notification.envelopeName,
                      ),
                      style: TextStyle(
                        fontWeight: notification.isRead
                            ? FontWeight.w600
                            : FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      DateFormat.yMMMd(locale).add_Hm().format(
                            notification.createdAt.toLocal(),
                          ),
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
