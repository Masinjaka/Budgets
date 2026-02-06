import 'package:budgets/features/stats/presentation/modules/authentication_utils.dart';
import 'package:budgets/core/currency/currency_provider.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BalanceCardType { expense, income }

class NewBalanceCard extends ConsumerStatefulWidget {
  final BalanceCardType type;
  final double amount;
  final IconData iconData;

  const NewBalanceCard({
    super.key,
    required this.type,
    required this.amount,
    required this.iconData,
  });

  @override
  ConsumerState<NewBalanceCard> createState() => _NewBalanceCardState();
}

class _NewBalanceCardState extends ConsumerState<NewBalanceCard> {
  bool _isHidden = true;

  void _toggleVisibility() {
    if (_isHidden) {
      AuthenticationUtils.authenticateAndShow(
        context,
        'Veuillez vous authentifier pour afficher le montant',
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
    final currencyState = ref.watch(currencyControllerProvider).value;
    final currencyCode = currencyState?.code ?? 'MGA';
    final rate = currencyState?.rateFor(currencyCode) ?? 1.0;
    final convertedAmount = convertFromMga(widget.amount.abs(), rate);
    final formattedAmount =
        formatAmountWithCurrency(convertedAmount, currencyCode);
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;
    final isExpense = widget.type == BalanceCardType.expense;
    final title = isExpense ? 'Dépense' : 'Revenue';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(6.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceDim,
                  borderRadius: BorderRadius.circular(2.w),
                ),
                child: Icon(widget.iconData,
                    color: textColor?.withValues(alpha: 0.7)),
              ),
              GestureDetector(
                onTap: _toggleVisibility,
                child: Icon(
                  _isHidden
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18.sp,
                  color: textColor?.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            _isHidden ? '••••••••' : formattedAmount,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: _isHidden ? 2.0 : 0.0,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: textColor?.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
