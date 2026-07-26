import 'package:budgets/core/ui/amount_visibility_scope.dart';
import 'package:flutter/material.dart';

class PrivacyText extends StatelessWidget {
  const PrivacyText(
    this.text, {
    this.hiddenText = '***',
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.textKey,
    super.key,
  });

  final String text;
  final String hiddenText;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final Key? textKey;

  @override
  Widget build(BuildContext context) {
    final isVisible = AmountVisibilityScope.isVisibleOf(context);
    final duration = Duration(milliseconds: isVisible ? 180 : 300);
    return AnimatedSize(
      duration: duration,
      curve: isVisible ? Curves.easeOutCubic : Curves.easeInOutCubic,
      alignment: _alignment,
      child: AnimatedSwitcher(
        duration: duration,
        reverseDuration: duration,
        switchInCurve: isVisible ? Curves.easeOutBack : Curves.easeInOutCubic,
        switchOutCurve: isVisible ? Curves.easeInCubic : Curves.easeInOutCubic,
        transitionBuilder: (child, animation) {
          final scale = Tween(begin: 0.92, end: 1.0).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: scale, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(isVisible),
          child: Text(
            isVisible ? text : hiddenText,
            key: textKey,
            style: style,
            maxLines: maxLines,
            overflow: overflow,
            textAlign: textAlign,
          ),
        ),
      ),
    );
  }

  Alignment get _alignment => switch (textAlign) {
        TextAlign.center => Alignment.center,
        TextAlign.end || TextAlign.right => Alignment.centerRight,
        _ => Alignment.centerLeft,
      };
}
