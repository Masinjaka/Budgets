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
  db = PowerSyncDatabase(
    schema: schema,
    path: await _getDatabasePath(),
  );
  await db.initialize();
  _initialized = true;

  SupabaseConnector? currentConnector;

  // If the user is already logged in, connect immediately
  if (_isLoggedIn()) {
    currentConnector = SupabaseConnector(powersyncUrl: powersyncUrl);
    db.connect(connector: currentConnector);
    _subscribeToStreams();
  }

  // React to auth state changes
  Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
    final event = data.event;
    if (event == AuthChangeEvent.signedIn) {
      currentConnector = SupabaseConnector(powersyncUrl: powersyncUrl);
      db.connect(connector: currentConnector!);
      _subscribeToStreams();
    } else if (event == AuthChangeEvent.signedOut) {
      currentConnector = null;
      await db.disconnect();
    } else if (event == AuthChangeEvent.tokenRefreshed) {
      currentConnector?.prefetchCredentials();
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
}

/// Disconnect and clear local data (used on sign-out).
Future<void> powerSyncLogout() async {
  await db.disconnectAndClear();
}
