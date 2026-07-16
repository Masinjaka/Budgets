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
bool _connectionRequested = false;
bool _streamsSubscribed = false;
Future<void>? _connectFuture;
Future<void>? _subscriptionFuture;
Future<void>? _logoutFuture;
bool _isLoggingOut = false;
int _subscriptionGeneration = 0;
final List<SyncStreamSubscription> _streamSubscriptions = [];

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
      _connectionRequested = false;
      _currentConnector = null;
      _connectFuture = null;
      _unsubscribeFromStreams();
      if (!db.closed) {
        await db.disconnect();
      }
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
Future<void> _subscribeToStreams() {
  if (_streamsSubscribed || _isLoggingOut || !_isLoggedIn()) {
    return Future<void>.value();
  }

  return _subscriptionFuture ??= _subscribeToStreamsAsync();
}

Future<void> _subscribeToStreamsAsync() async {
  final generation = _subscriptionGeneration;
  final streams = TypedSyncStreams(db);
  final subscriptions = <SyncStreamSubscription>[];

  try {
    for (final stream in [
      streams.user(),
      streams.transaction(),
      streams.categories(),
      streams.subcategories(),
      streams.subcategoryExpenses(),
      streams.budgets(),
      streams.budgetHistory(),
      streams.goals(),
      streams.subscriptions(),
      streams.notificationSettings(),
      streams.deviceTokens(),
      streams.budgetNotificationLog(),
    ]) {
      if (_isLoggingOut ||
          !_isLoggedIn() ||
          generation != _subscriptionGeneration) {
        _unsubscribe(subscriptions);
        return;
      }
      subscriptions.add(await stream.subscribe());
    }

    if (_isLoggingOut ||
        !_isLoggedIn() ||
        generation != _subscriptionGeneration) {
      _unsubscribe(subscriptions);
      return;
    }

    _streamSubscriptions.addAll(subscriptions);
    _streamsSubscribed = true;
  } catch (_) {
    _unsubscribe(subscriptions);
    rethrow;
  } finally {
    _subscriptionFuture = null;
  }
}

void _unsubscribeFromStreams() {
  _subscriptionGeneration++;
  _streamsSubscribed = false;
  _subscriptionFuture = null;
  _unsubscribe(_streamSubscriptions);
  _streamSubscriptions.clear();
}

void _unsubscribe(List<SyncStreamSubscription> subscriptions) {
  for (final subscription in subscriptions) {
    subscription.unsubscribe();
  }
}

Future<void> connectPowerSyncForCurrentUser({
  bool waitForSync = false,
  Duration timeout = const Duration(seconds: 10),
}) async {
  if (!_initialized || _isLoggingOut || !_isLoggedIn() || db.closed) return;
  final powersyncUrl = _powersyncUrl;
  if (powersyncUrl == null) return;

  // Calling PowerSyncDatabase.connect() while a sync client is already active
  // disconnects that client before starting a new one. Several application
  // paths call this helper, so keep one connection request for the entire
  // authenticated session and let PowerSync handle transient reconnects.
  if (!_connectionRequested) {
    final connector = SupabaseConnector(powersyncUrl: powersyncUrl);
    _currentConnector = connector;
    _connectionRequested = true;

    final connection = _startConnection(connector);
    _connectFuture = connection;
    try {
      await connection;
    } finally {
      if (identical(_connectFuture, connection)) {
        _connectFuture = null;
      }
    }
  } else {
    final pendingConnection = _connectFuture;
    if (pendingConnection != null) {
      await pendingConnection;
    }
  }
  if (_isLoggingOut || !_isLoggedIn() || db.closed) return;

  await _subscribeToStreams();

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

Future<void> _startConnection(SupabaseConnector connector) async {
  try {
    await db.connect(connector: connector);
  } catch (_) {
    // Permit a later call to retry only when this is still the active attempt.
    if (identical(_currentConnector, connector)) {
      _currentConnector = null;
      _connectionRequested = false;
    }
    rethrow;
  }
}

Future<void> flushPowerSyncUploads({
  Duration timeout = const Duration(seconds: 10),
}) async {
  if (!_initialized || _isLoggingOut || !_isLoggedIn() || db.closed) return;
  await connectPowerSyncForCurrentUser();

  final deadline = DateTime.now().add(timeout);
  while (true) {
    final stats = await db.getUploadQueueStats();
    if (stats.count == 0) return;

    final status = db.currentStatus;
    if (status.uploadError != null) {
      throw StateError('PowerSync upload failed: ${status.uploadError}');
    }

    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Timed out waiting for PowerSync uploads');
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}

/// Disconnect and clear local data (used on sign-out).
Future<void> powerSyncLogout({bool discardPendingChanges = false}) async {
  _logoutFuture ??= _powerSyncLogout(
    discardPendingChanges: discardPendingChanges,
  ).whenComplete(() {
    _logoutFuture = null;
  });
  await _logoutFuture;
}

Future<void> _powerSyncLogout({required bool discardPendingChanges}) async {
  if (!_initialized || db.closed) return;

  if (!discardPendingChanges) {
    await flushPowerSyncUploads();
  }

  _isLoggingOut = true;
  try {
    _connectionRequested = false;
    _currentConnector = null;
    _connectFuture = null;
    _unsubscribeFromStreams();
    await db.disconnectAndClear();
  } finally {
    _isLoggingOut = false;
  }
}
