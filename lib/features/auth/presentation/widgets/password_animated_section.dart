import 'package:flutter/material.dart';

class PasswordAnimatedSection extends StatelessWidget {
  const PasswordAnimatedSection({
    required this.isVisible,
    required this.child,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final bool isVisible;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        reverseDuration: const Duration(milliseconds: 190),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SizeTransition(
            sizeFactor: animation,
            axisAlignment: -1,
            child: child,
          ),
        ),
        child: isVisible
            ? Padding(
                key: const ValueKey(true),
                padding: padding,
                child: child,
              )
            : const SizedBox.shrink(key: ValueKey(false)),
      ),
    );
  }
}
