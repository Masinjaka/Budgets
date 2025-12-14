import 'package:budgets/features/categories/domain/models/subcategories.dart';
import 'package:budgets/widgets/custom_subcategory_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SubcategoryAmountRow extends StatelessWidget {
  final Map<String, dynamic> item;
  final List<Subcategory> subcategories;
  final VoidCallback? onRemove;
  final ValueChanged<String>? onAmountChanged;
  final ValueChanged<Subcategory?>? onSubcategoryChanged;
  final bool enabled;
  final VoidCallback? onSubcategoryTap;

  const SubcategoryAmountRow({
    super.key,
    required this.item,
    required this.subcategories,
    this.onRemove,
    this.onAmountChanged,
    this.onSubcategoryChanged,
    this.enabled = true,
    this.onSubcategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: onRemove != null ? 4.h : 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomSubcategoryDropdown(
                title: const SizedBox.shrink(),
                hint: 'Tapez ou sélectionnez une sous-catégorie',
                items: subcategories,
                selectedValue: item['subcategory'] as Subcategory?,
                onChanged: enabled ? onSubcategoryChanged : null,
                enabled: enabled,                onTap: onSubcategoryTap,              ),
              SizedBox(height: 1.h),
              TextFormField(
                controller: item['amountController'] as TextEditingController?,
                keyboardType: TextInputType.number,
                enabled: enabled,
                onChanged: onAmountChanged,
                decoration: InputDecoration(
                  hintText: '0.00',
                  isDense: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                ),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 18.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            ),
          ),
          if (onRemove != null)
            Positioned(
              top: 1.h,
              right: 1.w,
              child: GestureDetector(
                onTap: onRemove,
                child: Icon(
                  Icons.close,
                  color: Theme.of(context).iconTheme.color,
                  size: 20.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
