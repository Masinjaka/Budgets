import 'package:flutter/material.dart';

class AppResponsiveScope extends StatelessWidget {
  const AppResponsiveScope({required this.child, super.key});

  static const _referencePhoneWidth = 390.0;
  static const _maximumLayoutScale = 1.1;
  static const _maximumAccessibilityScale = 1.2;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final shortestSide = mediaQuery.size.shortestSide;
    final layoutScale = (shortestSide / _referencePhoneWidth).clamp(
      1.0,
      _maximumLayoutScale,
    );
    final systemScale = mediaQuery.textScaler.scale(1).clamp(
          1.0,
          _maximumAccessibilityScale,
        );
    final scale = systemScale > layoutScale ? systemScale : layoutScale;
    return MediaQuery(
      data: mediaQuery.copyWith(textScaler: TextScaler.linear(scale)),
      child: child,
    );
  }
}
