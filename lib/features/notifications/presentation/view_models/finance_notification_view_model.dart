import 'package:budgets/features/notifications/domain/models/finance_notification.dart';
import 'package:budgets/features/notifications/domain/repositories/finance_notification_repository.dart';
import 'package:flutter/foundation.dart';

class FinanceNotificationViewModel extends ChangeNotifier {
  FinanceNotificationViewModel(this._repository);

  final FinanceNotificationRepository _repository;
  List<FinanceNotification> _notifications = const [];
  bool _isLoading = false;

  List<FinanceNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount =>
      _notifications.where((notification) => !notification.isRead).length;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _notifications = List.unmodifiable(await _repository.notifications());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markRead(FinanceNotification notification) async {
    if (notification.isRead) return;
    await _repository.markRead(notification.id);
    _notifications = List.unmodifiable(
      _notifications.map(
        (item) =>
            item.id == notification.id ? item.copyWith(isRead: true) : item,
      ),
    );
    notifyListeners();
  }

  void clear() {
    _notifications = const [];
    notifyListeners();
  }
}
