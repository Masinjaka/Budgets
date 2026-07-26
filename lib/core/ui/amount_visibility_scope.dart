import 'package:budgets/core/ui/amount_visibility_controller.dart';
import 'package:flutter/widgets.dart';

class AmountVisibilityScope
    extends InheritedNotifier<AmountVisibilityController> {
  const AmountVisibilityScope({
    required this.controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  final AmountVisibilityController controller;

  static AmountVisibilityController? maybeControllerOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AmountVisibilityScope>()
        ?.controller;
  }

  static bool isVisibleOf(BuildContext context) {
    return maybeControllerOf(context)?.isVisible ?? true;
  }
}
