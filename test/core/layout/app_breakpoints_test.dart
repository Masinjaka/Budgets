import 'package:budgets/core/layout/app_breakpoints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('uses overlay navigation below the tablet breakpoint', () {
    expect(AppBreakpoints.usesPersistentNavigation(599), isFalse);
    expect(AppBreakpoints.mobileDrawerWidth(400), 330);
  });

  test('uses persistent navigation on tablet and large windows', () {
    expect(AppBreakpoints.usesPersistentNavigation(600), isTrue);
    expect(AppBreakpoints.sidebarWidth(900), 320);
    expect(AppBreakpoints.sidebarWidth(1200), 360);
  });
}
