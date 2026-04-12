import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'schema.dart';
import 'supabase_connector.dart';

/// Global PowerSync database instance.
late final PowerSyncDatabase db;

/// Whether PowerSync has been initialized.
bool _initialized = false;
String? _powersyncUrl;
SupabaseConnector? _currentConnector;
bool _streamsSubscribed = false;
Future<void>? _connectFuture;

bool get isPowerSyncInitialized => _initialized;

Future<String> _getDatabasePath() async {
  const dbFilename = 'budgets_powersync.db';
  if (kIsWeb) return dbFilename;
  final dir = await getApplicationSupportDirectory();
  return join(dir.path, dbFilename);
}

/// Initialize the PowerSync database and set up auth-driven connection.
///
/// Call this after Supabase has been initialized.
Future<void> openPowerSyncDatabase(String powersyncUrl) async {
  _powersyncUrl = powersyncUrl;
  db = PowerSyncDatabase(
    schema: schema,
    path: await _getDatabasePath(),
  );
  await db.initialize();
  _initialized = true;

  // If the user is already logged in, connect immediately
  if (_isLoggedIn()) {
    await connectPowerSyncForCurrentUser();
  }

  // React to auth state changes
  Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
    final event = data.event;
    if (event == AuthChangeEvent.signedIn) {
      await connectPowerSyncForCurrentUser();
    } else if (event == AuthChangeEvent.signedOut) {
      _currentConnector = null;
      _streamsSubscribed = false;
      await db.disconnect();
    } else if (event == AuthChangeEvent.tokenRefreshed) {
      _currentConnector?.prefetchCredentials();
    }
  });
}

bool _isLoggedIn() {
  return Supabase.instance.client.auth.currentSession?.accessToken != null;
}

/// Subscribe to all user-scoped sync streams.
/// Streams with auto_subscribe (exchange_rates, subscription_categories) are
/// handled automatically by the server.
void _subscribeToStreams() {
  if (_streamsSubscribed) return;
  final streams = TypedSyncStreams(db);
  streams.user().subscribe();
  streams.transaction().subscribe();
  streams.categories().subscribe();
  streams.subcategories().subscribe();
  streams.subcategoryExpenses().subscribe();
  streams.budgets().subscribe();
  streams.budgetHistory().subscribe();
  streams.goals().subscribe();
  streams.subscriptions().subscribe();
  streams.notificationSettings().subscribe();
  streams.deviceTokens().subscribe();
  streams.budgetNotificationLog().subscribe();
  _streamsSubscribed = true;
}

Future<void> connectPowerSyncForCurrentUser({
  bool waitForSync = false,
  Duration timeout = const Duration(seconds: 10),
}) async {
  if (!_initialized || !_isLoggedIn()) return;
  final powersyncUrl = _powersyncUrl;
  if (powersyncUrl == null) return;

  _currentConnector ??= SupabaseConnector(powersyncUrl: powersyncUrl);
  _connectFuture ??= db.connect(connector: _currentConnector!).whenComplete(() {
    _connectFuture = null;
  });
  await _connectFuture;
  _subscribeToStreams();

  if (!waitForSync || db.currentStatus.hasSynced == true) return;
  try {
    await db.waitForFirstSync().timeout(timeout);
  } on TimeoutException {
    debugPrint(
        'PowerSync: initial sync timed out; continuing with local cache');
  } catch (e) {
    debugPrint(
        'PowerSync: initial sync failed; continuing with local cache: $e');
  }
}

/// Disconnect and clear local data (used on sign-out).
Future<void> powerSyncLogout() async {
  _currentConnector = null;
  _streamsSubscribed = false;
  _connectFuture = null;
  await db.disconnectAndClear();
}
