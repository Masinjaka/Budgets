import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/notification_settings.dart';

class NotificationDataSource {
  NotificationDataSource(this._client);

  final SupabaseClient _client;

  Future<NotificationSettings> fetchSettings() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return NotificationSettings.defaults();
    }

    final data = await _client
        .from('notification_settings')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) {
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

    return NotificationSettings.fromMap(data);
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

    final payload = <String, dynamic>{
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
    };

    await _client.from('notification_settings').upsert(
          payload,
          onConflict: 'user_id',
        );
  }

  Future<void> upsertDeviceToken({
    required String token,
    required String platform,
    required bool enabled,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('device_tokens').upsert(
          {
            'token': token,
            'user_id': userId,
            'platform': platform,
            'enabled': enabled,
            'last_seen': DateTime.now().toUtc().toIso8601String(),
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          },
          onConflict: 'user_id,platform',
        );
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
