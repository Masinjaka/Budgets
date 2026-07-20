import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

/// Shows a dialog with Cupertino-style scale and fade animation.
///
/// This replaces [showDialog] with a custom transition that scales from 1.15
/// to 1.0 while fading in, similar to iOS dialogs.
Future<T?> showAnimatedDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  Offset? anchorPoint,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel ??
        MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: barrierColor ?? Colors.black54,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondaryAnimation) {
      final child = builder(context);
      if (useSafeArea) {
        return SafeArea(child: child);
      }
      return child;
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      final blur = Tween<double>(begin: 0.0, end: 6.0).animate(curvedAnimation);

      return AnimatedBuilder(
        animation: blur,
        builder: (context, _) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur.value, sigmaY: blur.value),
          child: ScaleTransition(
            scale:
                Tween<double>(begin: 0.85, end: 1.0).animate(curvedAnimation),
            child: FadeTransition(
              opacity: curvedAnimation,
              child: child,
            ),
          ),
        ),
      );
    },
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    anchorPoint: anchorPoint,
  );
}
