import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/notification_datasource.dart';
import '../../domain/models/notification_settings.dart';
import '../services/notification_service.dart';

final notificationControllerProvider =
    AsyncNotifierProvider<NotificationController, NotificationSettings>(
        NotificationController.new);

class NotificationController extends AsyncNotifier<NotificationSettings> {
  late final NotificationDataSource _dataSource;
  NotificationService? _service;

  @override
  Future<NotificationSettings> build() async {
    _dataSource = NotificationDataSource(Supabase.instance.client);
    _service = NotificationService(_dataSource);
    return _dataSource.fetchSettings();
  }

  Future<bool> setAllEnabled(bool enabled) async {
    return _applySettings(notificationsEnabled: enabled);
  }

  Future<bool> setRemindersEnabled(bool enabled) async {
    return _applySettings(remindersEnabled: enabled);
  }

  Future<bool> setWarningsEnabled(bool enabled) async {
    return _applySettings(warningsEnabled: enabled);
  }

  Future<bool> setReminderTime({
    required int hour,
    required int minute,
  }) async {
    return _applySettings(reminderHour: hour, reminderMinute: minute);
  }

  Future<void> refreshSettings() async {
    state = const AsyncLoading();
    state = AsyncData(await _dataSource.fetchSettings());
  }

  Future<void> registerIfEnabled() async {
    final current = state.asData?.value ?? await _dataSource.fetchSettings();
    if (!current.anyEnabled) {
      return;
    }
    await _service?.registerDevice();
  }

  Future<bool> _applySettings({
    bool? notificationsEnabled,
    bool? remindersEnabled,
    bool? warningsEnabled,
    int? reminderHour,
    int? reminderMinute,
  }) async {
    final current = state.value ?? await _dataSource.fetchSettings();
    final next = current.copyWith(
      notificationsEnabled:
          notificationsEnabled ?? current.notificationsEnabled,
      remindersEnabled: remindersEnabled ?? current.remindersEnabled,
      warningsEnabled: warningsEnabled ?? current.warningsEnabled,
      reminderHour: reminderHour ?? current.reminderHour,
      reminderMinute: reminderMinute ?? current.reminderMinute,
    );
    state = AsyncData(next);

    try {
      if (next.notificationsEnabled && !(current.notificationsEnabled)) {
        final granted = await _service?.registerDevice() ?? false;
        if (!granted) {
          state = AsyncData(current);
          return false;
        }
      }

      if (!next.notificationsEnabled) {
        await _service?.disableAllDevices();
      }

      await _dataSource.upsertSettings(
        notificationsEnabled: next.notificationsEnabled,
        remindersEnabled: next.remindersEnabled,
        warningsEnabled: next.warningsEnabled,
        reminderHour: next.reminderHour,
        reminderMinute: next.reminderMinute,
        timezoneOffsetMinutes: DateTime.now().timeZoneOffset.inMinutes,
      );

      return true;
    } catch (_) {
      state = AsyncData(current);
      rethrow;
    }
  }
}
