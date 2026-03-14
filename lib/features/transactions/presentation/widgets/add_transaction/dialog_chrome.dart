import 'package:budgets/core/enums/transaction_type.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class DialogHeader extends StatelessWidget {
  final TransactionType type;
  final VoidCallback onClose;

  const DialogHeader({super.key, required this.type, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            type == TransactionType.income ? 'Nouveau revenu' : 'Nouvelle dépense',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
          ),
        ),
        Container(
          decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.surface),
          child: IconButton(icon: const Icon(Icons.close), onPressed: onClose, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
        ),
      ],
    );
  }
}

class PerSubcategorySwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const PerSubcategorySwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(4.w),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Par sous-catégorie", style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500, fontSize: 15.sp)),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
