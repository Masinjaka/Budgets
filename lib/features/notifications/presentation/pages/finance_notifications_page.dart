import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/features/notifications/domain/models/finance_notification.dart';
import 'package:budgets/features/notifications/presentation/view_models/finance_notification_view_model.dart';
import 'package:budgets/features/notifications/presentation/widgets/finance_notification_list_item.dart';
import 'package:budgets/features/notifications/presentation/widgets/finance_notifications_empty_state.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/material.dart';

class FinanceNotificationsPage extends StatefulWidget {
  const FinanceNotificationsPage({
    required this.viewModel,
    required this.onSelected,
    super.key,
  });

  final FinanceNotificationViewModel viewModel;
  final Future<void> Function(
    BuildContext context,
    FinanceNotification notification,
  ) onSelected;

  @override
  State<FinanceNotificationsPage> createState() =>
      _FinanceNotificationsPageState();
}

class _FinanceNotificationsPageState extends State<FinanceNotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      await widget.viewModel.load();
    } catch (error) {
      if (mounted) showErrorToast(context, error);
    }
  }

  Future<void> _select(FinanceNotification notification) async {
    try {
      await widget.viewModel.markRead(notification);
      if (mounted) await widget.onSelected(context, notification);
    } catch (error) {
      if (mounted) showErrorToast(context, error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.notifications,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          if (widget.viewModel.isLoading &&
              widget.viewModel.notifications.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (widget.viewModel.notifications.isEmpty) {
            return const FinanceNotificationsEmptyState();
          }
          return RefreshIndicator(
            onRefresh: _load,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
              itemCount: widget.viewModel.notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notification = widget.viewModel.notifications[index];
                return FinanceNotificationListItem(
                  notification: notification,
                  onTap: () => _select(notification),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
