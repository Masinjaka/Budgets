import 'package:budgets/core/ui/amount_visibility_button.dart';
import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/core/ui/privacy_text.dart';
import 'package:budgets/features/notifications/presentation/view_models/finance_notification_view_model.dart';
import 'package:budgets/features/notifications/presentation/widgets/notification_inbox_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:budgets/l10n/app_localizations_context.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.drawerProgress,
    required this.onMenuPressed,
    required this.balance,
    required this.currencyCode,
    required this.notificationViewModel,
    required this.onNotificationsPressed,
    this.collapseProgress,
    super.key,
  });

  final Animation<double> drawerProgress;
  final VoidCallback onMenuPressed;
  final num balance;
  final String currencyCode;
  final FinanceNotificationViewModel notificationViewModel;
  final VoidCallback onNotificationsPressed;
  final ValueListenable<double>? collapseProgress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          AnimatedBuilder(
            animation: drawerProgress,
            builder: (context, child) => IgnorePointer(
              ignoring: drawerProgress.value > 0,
              child: Opacity(
                key: const Key('burger-menu-opacity'),
                opacity: 1 - drawerProgress.value,
                child: child,
              ),
            ),
            child: IconButton(
              onPressed: onMenuPressed,
              icon: const Icon(Icons.menu_rounded, size: 30),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(
                width: 80,
                height: 48,
              ),
              tooltip: context.l10n.menu,
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _overallBalanceLabel(context),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: PrivacyText(
                        _balanceLabel,
                        key: const Key('header-balance-label'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: AppTypography.body,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const AmountVisibilityButton(),
                  ],
                ),
              ],
            ),
          ),
          NotificationInboxButton(
            viewModel: notificationViewModel,
            onPressed: onNotificationsPressed,
          ),
        ],
      ),
    );
  }

  String get _balanceLabel {
    final amount =
        NumberFormat('#,##0.##', 'en_US').format(balance).replaceAll(',', ' ');
    return currencyCode == 'MGA' ? '$amount Ar' : '$amount $currencyCode';
  }

  Widget _overallBalanceLabel(BuildContext context) {
    final progress = collapseProgress;
    final colors = Theme.of(context).colorScheme;
    final expandedColor = colors.inverseSurface;
    final compactColor = colors.onSurfaceVariant;
    if (progress == null) return _label(context, compactColor);
    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) => _label(
        context,
        Color.lerp(
          expandedColor,
          compactColor,
          progress.value.clamp(0.0, 1.0),
        )!,
      ),
    );
  }

  Widget _label(BuildContext context, Color color) {
    return Text(
      context.l10n.overallBalance,
      key: const Key('overall-balance-label'),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: color,
        fontSize: AppTypography.caption,
        fontWeight: FontWeight.w600,
        height: 1,
      ),
    );
  }
}
