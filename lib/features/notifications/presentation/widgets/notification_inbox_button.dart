import 'package:budgets/features/notifications/presentation/view_models/finance_notification_view_model.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/material.dart';

class NotificationInboxButton extends StatelessWidget {
  const NotificationInboxButton({
    required this.viewModel,
    required this.onPressed,
    super.key,
  });

  final FinanceNotificationViewModel viewModel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => IconButton(
        key: const Key('notification-inbox-button'),
        onPressed: onPressed,
        icon: Transform.translate(
          offset: const Offset(4, 0),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_none_rounded, size: 29),
              if (viewModel.unreadCount > 0)
                const Positioned(
                  right: -5,
                  top: -5,
                  child: Icon(
                    Icons.warning_rounded,
                    key: Key('notification-warning-badge'),
                    color: Color(0xFFD84A3A),
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 80, height: 48),
        tooltip: context.l10n.notifications,
      ),
    );
  }
}
