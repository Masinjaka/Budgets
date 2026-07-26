import 'package:budgets/features/notifications/domain/models/finance_notification.dart';
import 'package:budgets/features/notifications/domain/repositories/finance_notification_repository.dart';

class EmptyFinanceNotificationRepository
    implements FinanceNotificationRepository {
  const EmptyFinanceNotificationRepository();

  @override
  Future<List<FinanceNotification>> notifications() async => const [];

  @override
  Future<void> markRead(String id) async {}
}
