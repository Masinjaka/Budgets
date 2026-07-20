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

  Future<void> setAllEnabled(bool enabled) async {
    await _applySettings(notificationsEnabled: enabled);
  }

  Future<void> setRemindersEnabled(bool enabled) async {
    await _applySettings(remindersEnabled: enabled);
  }

  Future<void> setWarningsEnabled(bool enabled) async {
    await _applySettings(warningsEnabled: enabled);
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

  Future<void> _applySettings({
    bool? notificationsEnabled,
    bool? remindersEnabled,
    bool? warningsEnabled,
  }) async {
    final previousValue = state.value;
    state = previousValue != null
        ? AsyncLoading<NotificationSettings>()
        : const AsyncLoading<NotificationSettings>();
    final current = await _dataSource.fetchSettings();
    final next = current.copyWith(
      notificationsEnabled:
          notificationsEnabled ?? current.notificationsEnabled,
      remindersEnabled: remindersEnabled ?? current.remindersEnabled,
      warningsEnabled: warningsEnabled ?? current.warningsEnabled,
    );

    if (next.notificationsEnabled && !(current.notificationsEnabled)) {
      final granted = await _service?.registerDevice() ?? false;
      if (!granted) {
        state = AsyncData(current);
        return;
      }
    }

    if (!next.notificationsEnabled) {
      await _service?.disableAllDevices();
    }

    await _dataSource.upsertSettings(
      notificationsEnabled: next.notificationsEnabled,
      remindersEnabled: next.remindersEnabled,
      warningsEnabled: next.warningsEnabled,
      timezoneOffsetMinutes: DateTime.now().timeZoneOffset.inMinutes,
    );

    state = AsyncData(next);
  }
}
