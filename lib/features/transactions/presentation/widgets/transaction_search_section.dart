import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/widgets/custom_search_bar.dart';
import 'package:budgets/widgets/category_filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Reusable search and filter section for transaction screens
class TransactionSearchSection extends StatelessWidget {
  final bool isSearchFocused;
  final VoidCallback onSearchFocused;
  final VoidCallback onSearchUnfocused;
  final VoidCallback onClearSearch;
  final TextEditingController searchController;
  final String hintText;
  final List<Category> availableCategories;
  final List<Category> selectedCategories;
  final Function(List<Category>) onCategorySelectionChanged;

  const TransactionSearchSection({
    super.key,
    required this.isSearchFocused,
    required this.onSearchFocused,
    required this.onSearchUnfocused,
    required this.onClearSearch,
    required this.searchController,
    required this.hintText,
    required this.availableCategories,
    required this.selectedCategories,
    required this.onCategorySelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar section
        AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          padding: EdgeInsets.fromLTRB(
              32,
              isSearchFocused ? 16 : 16, // Same padding whether focused or not
              32,
              8),
          child: Row(
            children: [
              Expanded(
                child: ReusableSearchBar(
                  isSearchFocused: isSearchFocused,
                  onSearchFocused: onSearchFocused,
                  onSearchUnfocused: onSearchUnfocused,
                  onClearSearch: onClearSearch,
                  controller: searchController,
                  hintText: hintText,
                ),
              ),
            ],
          ),
        ),
        // Show filter widget only when search is focused with animation
        if (isSearchFocused)
          Padding(
            padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
            child: CategoryFilterWidget(
              categories: availableCategories,
              selectedCategories: selectedCategories,
              onSelectionChanged: onCategorySelectionChanged,
            )
                .animate()
                .slideY(
                  begin: -0.3,
                  end: 0,
                  duration: 400.ms,
                  delay: 150.ms,
                  curve: Curves.easeOutCubic,
                )
                .fadeIn(
                  duration: 350.ms,
                  delay: 100.ms,
                  curve: Curves.easeInOut,
                ),
          ),
      ],
    );
  }
}
