import 'package:budgets/features/notifications/domain/models/finance_notification.dart';
import 'package:budgets/features/notifications/domain/repositories/finance_notification_repository.dart';

class FakeFinanceNotificationRepository
    implements FinanceNotificationRepository {
  FakeFinanceNotificationRepository([this.items = const []]);

  final List<FinanceNotification> items;
  final List<String> markedRead = [];

  @override
  Future<List<FinanceNotification>> notifications() async => items;

  @override
  Future<void> markRead(String id) async {
    markedRead.add(id);
  }
}
