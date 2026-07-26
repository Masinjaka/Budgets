import 'package:budgets/features/categories/domain/models/subcategories.dart';
import 'package:budgets/widgets/custom_subcategory_dropdown.dart';
import 'package:flutter/material.dart';

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
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: onRemove != null ? 32 : 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomSubcategoryDropdown(
                  title: const SizedBox.shrink(),
                  hint: 'Tapez ou sélectionnez une sous-catégorie',
                  items: subcategories,
                  selectedValue: item['subcategory'] as Subcategory?,
                  onChanged: enabled ? onSubcategoryChanged : null,
                  enabled: enabled,
                  onTap: onSubcategoryTap,
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller:
                      item['amountController'] as TextEditingController?,
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
                        EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          if (onRemove != null)
            Positioned(
              top: 8,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Icon(
                  Icons.close,
                  color: Theme.of(context).iconTheme.color,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
