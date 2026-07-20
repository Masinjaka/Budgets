import 'dart:async';

import 'package:flutter/foundation.dart';

class AuthRouterRefresh extends ChangeNotifier {
  AuthRouterRefresh(Stream<Object?> authChanges) {
    _subscription = authChanges.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
