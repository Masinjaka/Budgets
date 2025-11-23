import 'package:budgets/core/functions/transaction_utils.dart';
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:flutter/material.dart';

/// Mixin to handle common search and filter functionality for transaction tabs
mixin TransactionSearchMixin<T extends StatefulWidget> on State<T> {
  // Search state management
  bool isSearchFocused = false;
  late final TextEditingController searchController;

  // Selected categories for filtering
  List<Category> selectedCategories = [];

  // Locale initialization flag
  bool localeInitialized = false;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    _initializeLocale();
    searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void onSearchChanged() {
    setState(() {});
  }

  Future<void> _initializeLocale() async {
    await TransactionUtils.initializeFrenchLocale();
    if (mounted) {
      setState(() {
        localeInitialized = true;
      });
    }
  }

  void onCategorySelectionChanged(List<Category> categories) {
    setState(() {
      selectedCategories = categories;
    });
  }

  void onSearchFocused(AnimationController? appBarAnimationController) {
    setState(() {
      isSearchFocused = true;
    });
    appBarAnimationController?.animateTo(0.0);
  }

  void onSearchUnfocused(AnimationController? appBarAnimationController) {
    setState(() {
      isSearchFocused = false;
    });
    appBarAnimationController?.animateTo(1.0);
    FocusScope.of(context).unfocus();
  }

  void onClearSearch() {
    searchController.clear();
    // The listener will automatically trigger setState() when text changes
  }

  bool get hasFilters =>
      selectedCategories.isNotEmpty || searchController.text.isNotEmpty;
}
