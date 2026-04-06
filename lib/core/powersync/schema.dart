import 'package:powersync/powersync.dart';

final schema = Schema([
  Table('user', [
    Column.text('created_at'),
    Column.text('username'),
    Column.text('profile_photo'),
    Column.text('user_id'),
    Column.text('currency_code'),
  ]),
  Table('transaction', [
    Column.text('created_at'),
    Column.text('user_id'),
    Column.text('title'),
    Column.text('description'),
    Column.integer('amount'),
    Column.text('date'),
    Column.text('invoice_file'),
    Column.text('category_id'),
    Column.text('transaction_type'),
  ]),
  Table('categories', [
    Column.text('created_at'),
    Column.text('name'),
    Column.text('emoji'),
    Column.text('user_id'),
    Column.text('color'),
    Column.text('transaction_type'),
  ]),
  Table('subcategories', [
    Column.text('created_at'),
    Column.text('name'),
    Column.text('category_id'),
  ]),
  Table('subcategory_expenses', [
    Column.text('created_at'),
    Column.text('amount'),
    Column.text('sub_id'),
    Column.text('transaction_id'),
  ]),
  Table('budgets', [
    Column.text('created_at'),
    Column.text('user_id'),
    Column.text('category'),
    Column.text('amount'),
    Column.text('amount_spent'),
    Column.text('period'),
    Column.text('last_reset_at'),
  ]),
  Table('budget_history', [
    Column.text('created_at'),
    Column.integer('budget_id'),
    Column.text('user_id'),
    Column.text('category'),
    Column.text('amount'),
    Column.text('amount_spent'),
    Column.text('period_month'),
  ]),
  Table('goals', [
    Column.text('created_at'),
    Column.text('user_id'),
    Column.text('name'),
    Column.text('date_aim'),
    Column.text('goal_amount'),
    Column.text('current_amount'),
    Column.text('image_path'),
    Column.text('category'),
  ]),
  Table('subscriptions', [
    Column.text('created_at'),
    Column.text('user_id'),
    Column.text('title'),
    Column.text('description'),
    Column.text('amount'),
    Column.text('billing_cycle'),
    Column.integer('billing_day'),
    Column.text('start_date'),
    Column.integer('is_active'),
    Column.text('next_billing_date'),
    Column.text('category'),
  ]),
  Table('notification_settings', [
    Column.text('user_id'),
    Column.integer('reminders_enabled'),
    Column.integer('warnings_enabled'),
    Column.integer('reminder_hour'),
    Column.integer('reminder_minute'),
    Column.integer('timezone_offset_minutes'),
    Column.text('warning_threshold'),
    Column.text('last_reminder_sent_on'),
    Column.text('created_at'),
    Column.text('updated_at'),
    Column.integer('notifications_enabled'),
  ]),
  Table('device_tokens', [
    Column.text('user_id'),
    Column.text('token'),
    Column.text('platform'),
    Column.integer('enabled'),
    Column.text('last_seen'),
    Column.text('created_at'),
    Column.text('updated_at'),
  ]),
  Table('budget_notification_log', [
    Column.text('user_id'),
    Column.integer('budget_id'),
    Column.text('level'),
    Column.text('notified_on'),
    Column.text('created_at'),
  ]),
  Table('exchange_rates', [
    Column.text('base'),
    Column.text('rates'),
    Column.text('fetched_at'),
  ]),
  Table('subscription_categories', [
    Column.text('created_at'),
    Column.text('name'),
  ]),
]);

extension type TypedSyncStreams(PowerSyncDatabase _db) {
  SyncStream user() => _db.syncStream('user', {});
  SyncStream transaction() => _db.syncStream('transaction', {});
  SyncStream categories() => _db.syncStream('categories', {});
  SyncStream subcategories() => _db.syncStream('subcategories', {});
  SyncStream subcategoryExpenses() =>
      _db.syncStream('subcategory_expenses', {});
  SyncStream budgets() => _db.syncStream('budgets', {});
  SyncStream budgetHistory() => _db.syncStream('budget_history', {});
  SyncStream goals() => _db.syncStream('goals', {});
  SyncStream subscriptions() => _db.syncStream('subscriptions', {});
  SyncStream notificationSettings() =>
      _db.syncStream('notification_settings', {});
  SyncStream deviceTokens() => _db.syncStream('device_tokens', {});
  SyncStream budgetNotificationLog() =>
      _db.syncStream('budget_notification_log', {});
}
