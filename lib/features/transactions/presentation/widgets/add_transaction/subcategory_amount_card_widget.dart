import 'package:budgets/features/categories/domain/models/subcategories.dart';
import 'package:budgets/features/transactions/presentation/widgets/add_transaction/subcategory_amount_card.dart';
import 'package:flutter/material.dart';

class SubcategoryAmountCardWidget extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;
  final List<Subcategory> subcategories;
  final String? selectedCategoryId;
  final void Function(int) onRemove;
  final void Function(Map<String, dynamic>, Subcategory) onSubcategorySelected;
  final bool enabled;

  const SubcategoryAmountCardWidget({
    super.key,
    required this.item,
    required this.index,
    required this.subcategories,
    required this.selectedCategoryId,
    required this.onRemove,
    required this.onSubcategorySelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SubcategoryAmountCard(
      item: item,
      index: index,
      onRemove: onRemove,
      onSubcategoryTap: (item, index) async =>
          onSubcategorySelected(item, item['subcategory']),
    );
  }
}
