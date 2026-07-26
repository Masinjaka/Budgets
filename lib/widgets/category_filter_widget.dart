import 'package:budgets/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:budgets/features/categories/domain/models/category_model.dart';

class CategoryFilterWidget extends StatefulWidget {
  final List<Category> categories;
  final List<Category> selectedCategories;
  final Function(List<Category>) onSelectionChanged;

  const CategoryFilterWidget({
    super.key,
    required this.categories,
    required this.selectedCategories,
    required this.onSelectionChanged,
  });

  @override
  State<CategoryFilterWidget> createState() => _CategoryFilterWidgetState();
}

class _CategoryFilterWidgetState extends State<CategoryFilterWidget> {
  late List<Category> _selectedCategories;

  @override
  void initState() {
    super.initState();
    _selectedCategories = List.from(widget.selectedCategories);
  }

  void _toggleCategory(Category category) {
    setState(() {
      if (_selectedCategories
          .any((cat) => _areCategoriesEqual(cat, category))) {
        _selectedCategories
            .removeWhere((cat) => _areCategoriesEqual(cat, category));
      } else {
        _selectedCategories.add(category);
      }
    });
    widget.onSelectionChanged(_selectedCategories);
  }

  bool _isCategorySelected(Category category) {
    return _selectedCategories.any((cat) => _areCategoriesEqual(cat, category));
  }

  bool _areCategoriesEqual(Category cat1, Category cat2) {
    // Compare by ID if both have IDs, otherwise compare by name
    if (cat1.id != null && cat2.id != null) {
      return cat1.id == cat2.id;
    }
    return cat1.name == cat2.name;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.categories.map((category) {
          final isSelected = _isCategorySelected(category);
          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _toggleCategory(category),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (category.emoji != null &&
                        category.emoji!.isNotEmpty) ...[
                      Text(
                        category.emoji!,
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(width: 4),
                    ],
                    Text(
                      category.name ?? 'Unknown',
                      style: TextStyle(
                        color: isSelected
                            ? AppTheme.interactiveTextColor
                            : Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
