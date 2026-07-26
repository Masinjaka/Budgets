import 'package:budgets/features/notifications/data/repositories/empty_finance_notification_repository.dart';
import 'package:budgets/features/notifications/data/repositories/supabase_finance_notification_repository.dart';
import 'package:budgets/features/notifications/data/services/finance_notification_service.dart';
import 'package:budgets/features/notifications/domain/repositories/finance_notification_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FinanceNotificationRepositoryFactory {
  const FinanceNotificationRepositoryFactory._();

  static FinanceNotificationRepository create() {
    try {
      return SupabaseFinanceNotificationRepository(
        FinanceNotificationService(Supabase.instance.client),
      );
    } catch (_) {
      return const EmptyFinanceNotificationRepository();
    }
  }
}
