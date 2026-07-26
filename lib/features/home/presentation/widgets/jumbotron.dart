import 'package:budgets/core/currency/currency_provider.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:budgets/features/stats/domain/providers/stats_provider.dart';
import 'package:budgets/features/stats/presentation/modules/authentication_utils.dart';
import 'package:budgets/widgets/skeleton/home_skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';

class Jumbotron extends ConsumerStatefulWidget {
  const Jumbotron({
    super.key,
  });

  @override
  ConsumerState<Jumbotron> createState() => _JumbotronState();
}

class _JumbotronState extends ConsumerState<Jumbotron> {
  bool _isHidden = false;

  void _toggleVisibility() {
    if (_isHidden) {
      AuthenticationUtils.authenticateAndShow(
        context,
        'Veuillez vous authentifier pour afficher le solde',
        () {
          setState(() {
            _isHidden = false;
          });
        },
      );
    } else {
      setState(() {
        _isHidden = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncBalance = ref.watch(allTimeBalanceProvider);
    final currencyState = ref.watch(currencyControllerProvider);
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? const Color(0xFF1A1A1A);

    return Container(
      height: 128,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 16,
            left: 16,
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Solde total',
                style: TextStyle(
                  fontSize: 15.5,
                  color: textColor,
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: _toggleVisibility,
              child: AnimatedSwitcher(
                duration: 200.ms,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  _isHidden ? Ionicons.eye_off : Ionicons.eye,
                  key: ValueKey(_isHidden),
                  size: 18,
                  color: textColor.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          Positioned(
            top: 24,
            bottom: 24,
            left: 16,
            child: Align(
              alignment: Alignment.centerLeft,
              child: asyncBalance.when(
                data: (balance) {
                  final currency = currencyState.asData?.value;
                  if (currency == null) {
                    return const JumbotronAmountSkeleton();
                  }
                  final currencyCode = currency.code;
                  final rate = currency.rateFor(currencyCode);
                  final isNegative = balance < 0;
                  final displayAmount = convertFromMga(balance.abs(), rate);

                  return AnimatedSwitcher(
                    duration: 300.ms,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    child: _isHidden
                        ? Text(
                            '********',
                            key: const ValueKey('hidden'),
                            style: TextStyle(
                              fontSize: 22,
                              color: textColor,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.0,
                            ),
                          )
                        : Text(
                            '${isNegative ? '-' : ''}${formatAmountWithCurrency(displayAmount, currencyCode, preserveFraction: true)}',
                            key: const ValueKey('visible'),
                            style: TextStyle(
                              fontSize: 22,
                              color: isNegative ? Colors.red : textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  );
                },
                loading: () => const JumbotronAmountSkeleton(),
                error: (error, stack) => Text(
                  'Erreur',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
