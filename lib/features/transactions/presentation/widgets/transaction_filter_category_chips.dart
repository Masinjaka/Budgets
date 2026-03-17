import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TransactionFilterCategoryChips extends StatefulWidget {
  final List<Category> categories;
  final List<String> selectedCategories;
  final void Function(List<String>) onSelectionChanged;

  const TransactionFilterCategoryChips({
    super.key,
    required this.categories,
    required this.selectedCategories,
    required this.onSelectionChanged,
  });

  @override
  State<TransactionFilterCategoryChips> createState() =>
      _TransactionFilterCategoryChipsState();
}

class _TransactionFilterCategoryChipsState
    extends State<TransactionFilterCategoryChips> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedCategories);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 2.5.w,
      children: widget.categories.map((category) {
        final isSelected = _selected.contains(category.name);
        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selected.remove(category.name);
              } else {
                _selected.add(category.name ?? 'Inconnu');
              }
              widget.onSelectionChanged(List.from(_selected));
            });
          },
          splashColor: Colors.transparent,
          child: Container(
            margin: EdgeInsets.only(right: 2.w),
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).cardColor,
              border: Border.all(color: Colors.transparent),
              borderRadius: BorderRadius.circular(5.w),
            ),
            child: Text(
              category.name ?? 'Inconnu',
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 15.sp,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
