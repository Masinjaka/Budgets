import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/datasources/notification_datasource.dart';

class NotificationService {
  NotificationService(this._dataSource);

  final NotificationDataSource _dataSource;
  StreamSubscription<String>? _tokenSub;

  Future<void> bootstrapIfEnabled() async {
    print('🔔 [FCM] bootstrapIfEnabled called');
    final settings = await _dataSource.fetchSettings();
    print('🔔 [FCM] Settings fetched - anyEnabled: ${settings.anyEnabled}');
    if (!settings.anyEnabled) {
      print('🔔 [FCM] Notifications disabled in settings - skipping registration');
      return;
    }

    await _dataSource.upsertSettings(
      timezoneOffsetMinutes: DateTime.now().timeZoneOffset.inMinutes,
    );
    await registerDevice();
  }

  Future<bool> registerDevice() async {
    final permissionStatus = await Permission.notification.status;
    print('🔔 [FCM] Permission status: $permissionStatus');
    if (!permissionStatus.isGranted) {
      print('🔔 [FCM] Permission NOT granted - cannot register device');
      return false;
    }

    final token = await FirebaseMessaging.instance.getToken();
    print('🔔 [FCM] Token obtained: $token');
    if (token == null) {
      print('🔔 [FCM] Token is NULL - registration failed');
      return false;
    }

    await _dataSource.upsertDeviceToken(
      token: token,
      platform: _platformLabel(),
      enabled: true,
    );
    print('🔔 [FCM] Token saved to Supabase for platform: ${_platformLabel()}');

    _tokenSub ??= FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print('🔔 [FCM] Token refreshed: $newToken');
      _dataSource.upsertDeviceToken(
        token: newToken,
        platform: _platformLabel(),
        enabled: true,
      );
    });

    return true;
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
