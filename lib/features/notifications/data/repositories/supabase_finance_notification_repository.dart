import 'package:budgets/features/notifications/data/services/finance_notification_service.dart';
import 'package:budgets/features/notifications/domain/models/finance_notification.dart';
import 'package:budgets/features/notifications/domain/repositories/finance_notification_repository.dart';

class SupabaseFinanceNotificationRepository
    implements FinanceNotificationRepository {
  const SupabaseFinanceNotificationRepository(this._service);

  final FinanceNotificationService _service;

  @override
  Future<List<FinanceNotification>> notifications() async {
    final rows = await _service.notifications();
    return rows.map(FinanceNotification.fromJson).toList(growable: false);
  }

  @override
  Future<void> markRead(String id) => _service.markRead(id);
}
