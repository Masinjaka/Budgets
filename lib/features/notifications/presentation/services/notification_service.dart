import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'notification_permission_service.dart';

import '../../data/datasources/notification_datasource.dart';

class NotificationService {
  NotificationService(this._dataSource);

  final NotificationDataSource _dataSource;
  StreamSubscription<String>? _tokenSub;

  Future<void> bootstrapIfEnabled() async {
    final settings = await _dataSource.fetchSettings();
    if (!settings.anyEnabled) {
      return;
    }

    await _dataSource.upsertSettings(
      timezoneOffsetMinutes: DateTime.now().timeZoneOffset.inMinutes,
    );
    await registerDevice();
  }

  Future<bool> registerDevice() async {
    final hasPermission = await NotificationPermissionService().isGranted();
    if (!hasPermission) {
      return false;
    }

    if (_requiresApnsToken() && !await _waitForApnsToken()) {
      debugPrint('APNs token unavailable; FCM registration was deferred.');
      return false;
    }

    final token = await FirebaseMessaging.instance.getToken();
    if (token == null) {
      debugPrint('FCM returned no device token.');
      return false;
    }

    await _dataSource.upsertDeviceToken(
      token: token,
      platform: _platformLabel(),
      enabled: true,
    );

    _tokenSub ??= FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      _dataSource.upsertDeviceToken(
        token: newToken,
        platform: _platformLabel(),
        enabled: true,
      );
    });

    return true;
  }

  bool _requiresApnsToken() {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  Future<bool> _waitForApnsToken() async {
    for (var attempt = 0; attempt < 10; attempt++) {
      if (await FirebaseMessaging.instance.getAPNSToken() != null) return true;
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    return false;
  }

  Future<void> disableAllDevices() async {
    await _dataSource.setAllTokensEnabled(false);
  }

  void dispose() {
    _tokenSub?.cancel();
    _tokenSub = null;
  }

  String _platformLabel() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }
}
