import 'package:budgets/core/currency/currency_provider.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:budgets/features/stats/domain/providers/stats_provider.dart';
import 'package:budgets/features/stats/presentation/modules/authentication_utils.dart';
import 'package:budgets/widgets/skeleton/home_skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ionicons/ionicons.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class Jumbotron extends ConsumerStatefulWidget {
  const Jumbotron({
    super.key,
  });

  @override
  ConsumerState<Jumbotron> createState() => _JumbotronState();
}

class _JumbotronState extends ConsumerState<Jumbotron> {
  bool _isHidden = true;

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
    final currencyState = ref.watch(currencyControllerProvider).value;
    final currencyCode = currencyState?.code ?? 'MGA';
    final rate = currencyState?.rateFor(currencyCode) ?? 1.0;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Container(
      height: 16.h,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 2.h,
            left: 2.h,
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Solde total',
                style: TextStyle(
                  fontSize: 15.5.sp,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
          Positioned(
            top: 2.h,
            right: 2.h,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
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
                      size: 18.sp,
                      color: textColor?.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.w),
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: Text(
                    currencyCode,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 3.h,
            bottom: 3.h,
            left: 2.h,
            child: Align(
              alignment: Alignment.centerLeft,
              child: asyncBalance.when(
                data: (balance) {
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
                            '••••••••',
                            key: const ValueKey('hidden'),
                            style: TextStyle(
                              fontSize: 22.sp,
                              color: textColor,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.0,
                            ),
                          )
                        : Text(
                            '${isNegative ? '-' : ''}${formatAmountValue(displayAmount)}',
                            key: const ValueKey('visible'),
                            style: TextStyle(
                              fontSize: 22.sp,
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
                    fontSize: 25.sp,
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
