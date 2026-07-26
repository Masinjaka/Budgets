import 'package:budgets/features/notifications/domain/models/finance_notification.dart';

abstract interface class FinanceNotificationRepository {
  Future<List<FinanceNotification>> notifications();

  Future<void> markRead(String id);
}
