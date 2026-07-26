import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void usePhoneWindow(WidgetTester tester) {
  _setWindow(tester, const Size(400, 800));
}

void useWidePhoneWindow(WidgetTester tester) {
  _setWindow(tester, const Size(484, 900));
}

void useTabletWindow(WidgetTester tester) {
  _setWindow(tester, const Size(900, 1100));
}

void _setWindow(WidgetTester tester, Size size) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });
}
