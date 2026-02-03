import 'package:budgets/features/stats/presentation/modules/authentication_utils.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:budgets/core/utils/amount_formatter.dart';

enum BalanceCardType { expense, income }

class NewBalanceCard extends StatefulWidget {
  final BalanceCardType type;
  final double amount;

  const NewBalanceCard({
    super.key,
    required this.type,
    required this.amount,
  });

  @override
  State<NewBalanceCard> createState() => _NewBalanceCardState();
}

class _NewBalanceCardState extends State<NewBalanceCard> {
  bool _isHidden = true;

  String _formatAmount(double amount) {
    return formatAmountValue(amount.abs(), includeCurrency: true);
  }

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
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;
    final isExpense = widget.type == BalanceCardType.expense;
    final title = isExpense ? 'Dépense' : 'Revenue';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.5.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: textColor?.withValues(alpha: 0.7),
                ),
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
            _isHidden ? '••••••••' : _formatAmount(widget.amount),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: _isHidden ? 2.0 : 0.0,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
