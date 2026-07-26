import 'package:budgets/core/ui/amount_visibility_scope.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AmountVisibilityButton extends StatelessWidget {
  const AmountVisibilityButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AmountVisibilityScope.maybeControllerOf(context);
    final isVisible = controller?.isVisible ?? true;
    final label =
        isVisible ? context.l10n.hideBalance : context.l10n.showBalance;
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        child: InkResponse(
          onTap: controller?.toggle,
          radius: 18,
          child: SizedBox(
            key: const Key('balance-visibility-toggle'),
            width: 30,
            height: 30,
            child: Center(
              child: Icon(
                isVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                key: ValueKey(isVisible),
                size: 18,
              )
                  .animate(key: ValueKey('privacy-eye-$isVisible'))
                  .fadeIn(duration: 150.ms, curve: Curves.easeOut)
                  .scale(
                    begin: const Offset(1, 0.18),
                    end: const Offset(1, 1),
                    duration: 220.ms,
                    curve: Curves.easeOutBack,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
