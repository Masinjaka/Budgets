import 'package:flutter/foundation.dart';

abstract final class DevelopmentLog {
  static void error(
    String operation,
    Object error, [
    StackTrace? stackTrace,
  ]) {
    if (!kDebugMode) return;
    debugPrint('[Drala][$operation] $error');
    if (stackTrace != null) {
      debugPrintStack(
        label: '[Drala][$operation] stack trace',
        stackTrace: stackTrace,
      );
    }
  }
}
