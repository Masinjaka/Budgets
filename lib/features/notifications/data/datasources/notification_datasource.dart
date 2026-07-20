import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/notification_settings.dart';

const _uuid = Uuid();

class NotificationDataSource {
  NotificationDataSource(this._client);

  final SupabaseClient _client;

  Future<NotificationSettings> fetchSettings() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return NotificationSettings.defaults();

    final row = await _client
        .from('notification_settings')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (row == null) {
      final defaults = NotificationSettings.defaults(
        timezoneOffsetMinutes: DateTime.now().timeZoneOffset.inMinutes,
      );
      await upsertSettings(
        notificationsEnabled: defaults.notificationsEnabled,
        remindersEnabled: defaults.remindersEnabled,
        warningsEnabled: defaults.warningsEnabled,
        reminderHour: defaults.reminderHour,
        reminderMinute: defaults.reminderMinute,
        timezoneOffsetMinutes: defaults.timezoneOffsetMinutes,
        warningThreshold: defaults.warningThreshold,
      );
      return defaults;
    }

    return NotificationSettings(
      notificationsEnabled: row['notifications_enabled'] as bool? ?? true,
      remindersEnabled: row['reminders_enabled'] as bool? ?? true,
      warningsEnabled: row['warnings_enabled'] as bool? ?? true,
      reminderHour: row['reminder_hour'] as int? ?? 10,
      reminderMinute: row['reminder_minute'] as int? ?? 0,
      timezoneOffsetMinutes: row['timezone_offset_minutes'] as int? ?? 0,
      warningThreshold:
          double.tryParse(row['warning_threshold'].toString()) ?? 0.9,
    );
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

    await _client.from('notification_settings').upsert({
      'user_id': userId,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (remindersEnabled != null) 'reminders_enabled': remindersEnabled,
      if (warningsEnabled != null) 'warnings_enabled': warningsEnabled,
      if (reminderHour != null) 'reminder_hour': reminderHour,
      if (reminderMinute != null) 'reminder_minute': reminderMinute,
      if (timezoneOffsetMinutes != null)
        'timezone_offset_minutes': timezoneOffsetMinutes,
      if (warningThreshold != null) 'warning_threshold': warningThreshold,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id');
  }

  Future<void> upsertDeviceToken({
    required String token,
    required String platform,
    required bool enabled,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    var row = await _client
        .from('device_tokens')
        .select('id')
        .eq('user_id', userId)
        .eq('token', token)
        .maybeSingle();
    row ??= await _client
        .from('device_tokens')
        .select('id')
        .eq('user_id', userId)
        .eq('platform', platform)
        .limit(1)
        .maybeSingle();

    final now = DateTime.now().toUtc().toIso8601String();
    final values = {
      'token': token,
      'user_id': userId,
      'platform': platform,
      'enabled': enabled,
      'last_seen': now,
      'updated_at': now,
    };
    if (row == null) {
      await _client.from('device_tokens').insert({
        'id': _uuid.v4(),
        ...values,
        'created_at': now,
      });
    } else {
      await _client
          .from('device_tokens')
          .update(values)
          .eq('id', row['id'] as String);
    }
  }

  Future<void> setAllTokensEnabled(bool enabled) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.from('device_tokens').update({
      'enabled': enabled,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('user_id', userId);
  }
}
