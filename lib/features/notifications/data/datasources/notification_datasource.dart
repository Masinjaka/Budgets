import 'package:budgets/core/powersync/powersync.dart' as powersync;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/notification_settings.dart';

const _uuid = Uuid();

class NotificationDataSource {
  NotificationDataSource(this._client);

  final SupabaseClient _client;

  Future<NotificationSettings> fetchSettings() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return NotificationSettings.defaults();
    }

    // Read from PowerSync local database
    final results = await powersync.db.getAll('''
      SELECT reminders_enabled, warnings_enabled, reminder_hour,
             reminder_minute, timezone_offset_minutes, warning_threshold,
             notifications_enabled
      FROM notification_settings
      WHERE user_id = ?
      LIMIT 1
    ''', [userId]);

    if (results.isEmpty) {
      final defaults = NotificationSettings.defaults(
        timezoneOffsetMinutes: DateTime.now().timeZoneOffset.inMinutes,
      );
      await upsertSettings(
        remindersEnabled: defaults.remindersEnabled,
        warningsEnabled: defaults.warningsEnabled,
        reminderHour: defaults.reminderHour,
        reminderMinute: defaults.reminderMinute,
        timezoneOffsetMinutes: defaults.timezoneOffsetMinutes,
        warningThreshold: defaults.warningThreshold,
      );
      return defaults;
    }

    final row = results.first;
    return NotificationSettings(
      notificationsEnabled: _intToBool(row['notifications_enabled']),
      remindersEnabled: _intToBool(row['reminders_enabled']),
      warningsEnabled: _intToBool(row['warnings_enabled']),
      reminderHour: row['reminder_hour'] as int? ?? 10,
      reminderMinute: row['reminder_minute'] as int? ?? 0,
      timezoneOffsetMinutes: row['timezone_offset_minutes'] as int? ?? 0,
      warningThreshold: row['warning_threshold'] != null
          ? double.tryParse(row['warning_threshold'].toString()) ?? 0.9
          : 0.9,
    );
  }

  /// Convert SQLite integer (0/1) to bool, handling both int and bool inputs
  bool _intToBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    return true; // default
  }

  Future<void> upsertSettings({
    bool? notificationsEnabled,
    bool? remindersEnabled,
    bool? warningsEnabled,
    int? reminderHour,
    int? reminderMinute,
    int? timezoneOffsetMinutes,
    double? warningThreshold,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final nowIso = DateTime.now().toUtc().toIso8601String();

    // Check if a row exists for this user
    final existing = await powersync.db.getAll(
      'SELECT id FROM notification_settings WHERE user_id = ? LIMIT 1',
      [userId],
    );

    if (existing.isEmpty) {
      // INSERT new row — PowerSync id maps to user_id for this table
      await powersync.db.execute(
        '''INSERT INTO notification_settings
           (id, user_id, notifications_enabled, reminders_enabled,
            warnings_enabled, reminder_hour, reminder_minute,
            timezone_offset_minutes, warning_threshold, created_at, updated_at)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)''',
        [
          userId, // id = user_id for this table (PK is user_id)
          userId,
          notificationsEnabled ?? true ? 1 : 0,
          remindersEnabled ?? true ? 1 : 0,
          warningsEnabled ?? true ? 1 : 0,
          reminderHour ?? 10,
          reminderMinute ?? 0,
          timezoneOffsetMinutes ?? 0,
          warningThreshold?.toString() ?? '0.9',
          nowIso,
          nowIso,
        ],
      );
    } else {
      // UPDATE existing row
      final updates = <String>[];
      final values = <dynamic>[];

      if (notificationsEnabled != null) {
        updates.add('notifications_enabled = ?');
        values.add(notificationsEnabled ? 1 : 0);
      }
      if (remindersEnabled != null) {
        updates.add('reminders_enabled = ?');
        values.add(remindersEnabled ? 1 : 0);
      }
      if (warningsEnabled != null) {
        updates.add('warnings_enabled = ?');
        values.add(warningsEnabled ? 1 : 0);
      }
      if (reminderHour != null) {
        updates.add('reminder_hour = ?');
        values.add(reminderHour);
      }
      if (reminderMinute != null) {
        updates.add('reminder_minute = ?');
        values.add(reminderMinute);
      }
      if (timezoneOffsetMinutes != null) {
        updates.add('timezone_offset_minutes = ?');
        values.add(timezoneOffsetMinutes);
      }
      if (warningThreshold != null) {
        updates.add('warning_threshold = ?');
        values.add(warningThreshold.toString());
      }

      updates.add('updated_at = ?');
      values.add(nowIso);

      values.add(userId);

      if (updates.isNotEmpty) {
        await powersync.db.execute(
          'UPDATE notification_settings SET ${updates.join(', ')} WHERE user_id = ?',
          values,
        );
      }
    }
  }

  Future<void> upsertDeviceToken({
    required String token,
    required String platform,
    required bool enabled,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final nowIso = DateTime.now().toUtc().toIso8601String();

    // Check if a row exists for this user+platform
    final existing = await powersync.db.getAll(
      'SELECT id FROM device_tokens WHERE user_id = ? AND platform = ? LIMIT 1',
      [userId, platform],
    );

    if (existing.isEmpty) {
      final tokenId = _uuid.v4();
      await powersync.db.execute(
        '''INSERT INTO device_tokens
           (id, token, user_id, platform, enabled, last_seen, created_at, updated_at)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?)''',
        [tokenId, token, userId, platform, enabled ? 1 : 0, nowIso, nowIso, nowIso],
      );
    } else {
      await powersync.db.execute(
        '''UPDATE device_tokens
           SET token = ?, enabled = ?, last_seen = ?, updated_at = ?
           WHERE user_id = ? AND platform = ?''',
        [token, enabled ? 1 : 0, nowIso, nowIso, userId, platform],
      );
    }
  }

  Future<void> setAllTokensEnabled(bool enabled) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final nowIso = DateTime.now().toUtc().toIso8601String();

    await powersync.db.execute(
      'UPDATE device_tokens SET enabled = ?, updated_at = ? WHERE user_id = ?',
      [enabled ? 1 : 0, nowIso, userId],
    );
  }
}
