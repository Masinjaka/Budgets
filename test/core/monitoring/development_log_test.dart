import 'package:budgets/core/monitoring/development_log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('writes operation and backend error details in debug mode', () {
    final messages = <String>[];
    final previous = debugPrint;
    debugPrint = (message, {wrapWidth}) => messages.add(message ?? '');
    addTearDown(() => debugPrint = previous);

    DevelopmentLog.error(
      'process receipt',
      StateError('database signature mismatch'),
    );

    expect(messages.join('\n'), contains('[Drala][process receipt]'));
    expect(messages.join('\n'), contains('database signature mismatch'));
  });
}
