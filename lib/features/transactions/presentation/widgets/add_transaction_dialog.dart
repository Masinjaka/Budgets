import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/core/utils/animated_dialog.dart';
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/features/categories/domain/models/subcategories.dart';
import 'package:budgets/features/categories/presentation/widgets/add_category_dialog.dart';
import 'package:budgets/features/categories/presentation/widgets/subcategory_selection_dialog.dart';
import 'package:budgets/features/transactions/presentation/modules/transaction_module.dart';
import 'package:budgets/widgets/animated_amount_field.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// A dialog for quickly adding a new transaction.
/// For more detailed operations (subcategories, edit mode), use TransactionCreationPage.
class AddTransactionDialog extends ConsumerStatefulWidget {
  final TransactionType transactionType;

  const AddTransactionDialog({
    super.key,
    required this.transactionType,
  });

  /// Shows the add transaction dialog and returns true if a transaction was created.
  static Future<bool?> show(
    BuildContext context, {
    required TransactionType transactionType,
  }) {
    return showAnimatedDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AddTransactionDialog(
        transactionType: transactionType,
      ),
    );
  }

  @override
  ConsumerState<AddTransactionDialog> createState() =>
      _AddTransactionDialogState();
}

class _AddTransactionDialogState extends ConsumerState<AddTransactionDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TransactionModule _module = TransactionModule();

  final TextEditingController _montantController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _isLoading = false;
  bool _isInitializing = true;
  bool _isPerSubcategory = false;

  // Subcategory state
  List<Subcategory> _subcategories = [];
  final List<Map<String, dynamic>> _subcategoryAmounts = [];
  final Set<int> _removingIndices = {}; // Track items being animated out
  final PageController _subcategoryPageController = PageController(
    viewportFraction: 0.85,
  );

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _togglePerSubcategory(bool value) {
    setState(() {
      _isPerSubcategory = value;
      if (!value) {
        // Clear all subcategory amounts when toggling off
        _clearAllSubcategoryAmounts();
      }
    });
  }

  void _clearAllSubcategoryAmounts() {
    if (_subcategoryAmounts.isEmpty) return;

    // Dispose all controllers
    for (var item in _subcategoryAmounts) {
      item['subcategoryController']?.dispose();
      item['amountController']?.dispose();
    }

    _subcategoryAmounts.clear();
    setState(() {});
  }

  void _addSubcategoryAmountCard() {
    // Check if category is selected first
    if (_selectedCategory == null) {
      Fluttertoast.showToast(
        msg: 'Veuillez d\'abord sélectionner une catégorie principale',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final newItem = _module.createSubcategoryAmountItem();
    _subcategoryAmounts.add(newItem);
    setState(() {});

    // Animate to the newly added card (before the add button)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_subcategoryPageController.hasClients) {
        _subcategoryPageController.animateToPage(
          _subcategoryAmounts.length - 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _removeSubcategoryAmountCard(int index) {
    if (index >= _subcategoryAmounts.length) return;
    if (_removingIndices.contains(index)) return; // Already removing

    // Calculate the target page to scroll to (item to the left, or stay at 0)
    final targetPage = index > 0 ? index - 1 : 0;

    // Mark as removing to trigger animation
    setState(() {
      _removingIndices.add(index);
    });

    // After animation completes, actually remove the item
    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;

      final removedItem = _subcategoryAmounts[index];

      // Dispose controllers
      removedItem['subcategoryController']?.dispose();
      removedItem['amountController']?.dispose();

      setState(() {
        _removingIndices.remove(index);
        // Update remaining indices in the set
        _removingIndices.clear(); // Clear since indices shift after removal
        _subcategoryAmounts.removeAt(index);
      });

      // Scroll to the item to the left of the deleted one
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_subcategoryPageController.hasClients &&
            _subcategoryAmounts.isNotEmpty) {
          _subcategoryPageController.animateToPage(
            targetPage.clamp(0, _subcategoryAmounts.length - 1),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
          );
        }
      });
    });
  }

  Future<void> _loadCategories() async {
    try {
      final allCategories = await _module.fetchCategories(ref);
      final filteredCategories = allCategories
          .where(
              (category) => category.transactionType == widget.transactionType)
          .toList();

      if (mounted) {
        setState(() {
          _categories = filteredCategories;
          _isInitializing = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading categories: $e");
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _montantController.dispose();
    _descriptionController.dispose();
    _subcategoryPageController.dispose();
    // Dispose subcategory controllers
    for (var item in _subcategoryAmounts) {
      item['subcategoryController']?.dispose();
      item['amountController']?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Dialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.w),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
        child: _isInitializing
            ? SizedBox(
                height: 30.h,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(5.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.transactionType == TransactionType.income
                                    ? 'Nouveau revenu'
                                    : 'Nouvelle dépense',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(4.w),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Par sous-catégorie",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15.sp,
                                    ),
                              ),
                              Switch(
                                value: _isPerSubcategory,
                                onChanged: (val) {
                                  _togglePerSubcategory(val);
                                },
                                // activeThumbColor: AppTheme.primaryGreen,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 1.h),

                        // Amount field with scale animation
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: SizeTransition(
                                sizeFactor: animation,
                                axisAlignment: -1.0,
                                child: child,
                              ),
                            );
                          },
                          child: _isPerSubcategory
                              ? const SizedBox.shrink(key: ValueKey('empty'))
                              : AnimatedAmountField(
                                  key: const ValueKey('amountField'),
                                  controller: _montantController,
                                  hint: '0.00',
                                  fontSize: 28.sp,
                                  fillColor:
                                      Theme.of(context).colorScheme.surfaceDim,
                                  height: 15.h,
                                  width: double.infinity,
                                  borderRadius: BorderRadius.circular(3.w),
                                ),
                        ),
                        SizedBox(height: 2.h),

                        // Category pills with slide animation
                        AnimatedSlide(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          offset: Offset.zero,
                          child: _buildCategoryPills(),
                        ),
                        SizedBox(height: 2.h),

                        // Subcategory fields with scale up animation
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              alignment: Alignment.topCenter,
                              child: SizeTransition(
                                sizeFactor: animation,
                                axisAlignment: -1.0,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: _isPerSubcategory
                              ? Column(
                                  key: const ValueKey('subcategoryFields'),
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildSubcategoryAmountFields(),
                                    SizedBox(height: 2.h),
                                  ],
                                )
                              : const SizedBox.shrink(
                                  key: ValueKey('emptySubcategory')),
                        ),
                        // Description field

                        CustomTextField(
                          title: Text(
                            'Description (optionnel)',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
                          hint: 'Ajouter une description',
                          controller: _descriptionController,
                          keyboardType: TextInputType.text,
                          maxLines: 2,
                          borderRadius: BorderRadius.circular(3.w),
                        ),
                        SizedBox(height: 3.h),

                        // Submit button
                        CustomButton(
                          text: 'Confirmer',
                          backgroundColor: Theme.of(context).primaryColor,
                          onPressed: _submitTransaction,
                          isLoading: _isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildCategoryPills() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Catégorie ${_isPerSubcategory ? "principale" : ""}',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15.5.sp,
          ),
        ),
        SizedBox(height: 1.h),
        SizedBox(
          height: 5.h,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5.h),
            child: ListView(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              children: [
                // Existing category pills
                ..._categories.map((category) => _buildCategoryPill(category)),
                // Add category pill
                _buildAddCategoryPill(),
              ],
            ),
          ),
        ),
        // Show error if no category selected during validation
        // if (_selectedCategory == null &&
        //     _formKey.currentState?.validate() == false)
        //   Padding(
        //     padding: EdgeInsets.only(top: 1.h),
        //     child: Text(
        //       'Veuillez sélectionner une catégorie',
        //       style: TextStyle(
        //         color: Theme.of(context).colorScheme.error,
        //         fontSize: 12.sp,
        //       ),
        //     ),
        //   ),
      ],
    );
  }

  Widget _buildCategoryPill(Category category) {
    final isSelected = _selectedCategory?.id == category.id;
    final emoji = category.emoji ?? '📁';

    return GestureDetector(
      onTap: () async {
        final previousCategory = _selectedCategory;

        // Only process if selecting a different category
        if (category.id == previousCategory?.id) {
          return; // Same category, do nothing
        }

        // Clear existing subcategory amounts BEFORE fetching new ones
        // This ensures we don't clear cards added after the fetch starts
        if (_subcategoryAmounts.isNotEmpty) {
          _clearAllSubcategoryAmounts();
        }

        setState(() {
          _selectedCategory = category;
          _subcategories = []; // Clear old subcategories immediately
        });

        // Fetch subcategories for the new category
        if (category.id != null) {
          try {
            final subcategories =
                await _module.fetchSubcategories(ref, category.id!);
            if (mounted) {
              setState(() {
                _subcategories = subcategories;
              });
            }
          } catch (e) {
            debugPrint("Error fetching subcategories: $e");
            if (mounted) {
              setState(() {
                _subcategories = [];
              });
            }
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(right: 2.w),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.inverseSurface
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(5.h),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: TextStyle(fontSize: 14.sp),
            ),
            SizedBox(width: 1.5.w),
            Text(
              category.name ?? '',
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onInverseSurface
                    : Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withAlpha(200),
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCategoryPill() {
    final textColor =
        Theme.of(context).textTheme.bodyMedium?.color?.withAlpha(200);

    return GestureDetector(
      onTap: () async {
        // Show add category dialog
        final newCategory = await AddCategoryDialog.show(
          context,
          transactionType: widget.transactionType,
        );

        // If a category was created, reload categories and select it
        if (newCategory != null) {
          await _loadCategories();
          // Find and select the newly created category
          final createdCategory = _categories.firstWhere(
            (c) => c.name == newCategory.name,
            orElse: () => newCategory,
          );
          setState(() {
            _selectedCategory = createdCategory;
          });
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(5.h),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              size: 14.sp,
              color: textColor,
            ),
            SizedBox(width: 1.w),
            Text(
              'Ajouter une catégorie',
              style: TextStyle(
                color: textColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitTransaction() async {
    // Check if category is selected
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une catégorie'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate subcategory amounts if in per-subcategory mode
    if (_isPerSubcategory) {
      if (_subcategoryAmounts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez ajouter au moins une sous-catégorie'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (!_module.validateSubcategoryAmounts(_subcategoryAmounts)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Veuillez remplir toutes les sous-catégories et montants'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    final result = await _module.submitTransaction(
      formKey: _formKey,
      selectedCategory: _selectedCategory,
      isMultipleAmounts: _isPerSubcategory,
      subcategoryAmounts: _subcategoryAmounts,
      montantController: _montantController,
      descriptionController: _descriptionController,
      transactionType: widget.transactionType,
      ref: ref,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    // Show result message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? Colors.green : Colors.red,
      ),
    );

    // Close dialog on success
    if (result.success) {
      Navigator.of(context).pop(true);
    }
  }

  Widget _buildSubcategoryAmountFields() {
    return SizedBox(
      height: 20.h,
      child: PageView.builder(
        controller: _subcategoryPageController,
        padEnds: false,
        // +1 for the add button at the end
        itemCount: _subcategoryAmounts.length + 1,
        itemBuilder: (context, index) {
          // Last item is always the add button
          if (index == _subcategoryAmounts.length) {
            return _buildAddSubcategoryAmountCard();
          }

          final isRemoving = _removingIndices.contains(index);

          return AnimatedScale(
            scale: isRemoving ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInBack,
            child: AnimatedOpacity(
              opacity: isRemoving ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: _buildSubcategoryAmountCard(
                _subcategoryAmounts[index],
                index,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubcategoryAmountCard(
    Map<String, dynamic> item,
    int index, {
    bool enabled = true,
  }) {
    final amountController = item['amountController'] as TextEditingController;
    final subcategoryName = item['subcategoryName'] as String? ?? '';

    return Container(
      margin: EdgeInsets.only(right: 3.w),
      height: 20.h,
      width: 70.w,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(4.w),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Amount field with animated digits
                  AnimatedSubcategoryAmountField(
                    controller: amountController,
                    hint: '0.00',
                    fontSize: 25.sp,
                    fillColor: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                  SizedBox(height: 1.h),
                  // Subcategory selector button
                  GestureDetector(
                    onTap:
                        enabled ? () => _onSubcategoryTap(item, index) : null,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceDim,
                        borderRadius: BorderRadius.circular(5.w),
                      ),
                      child: Text(
                        subcategoryName.isNotEmpty
                            ? subcategoryName
                            : 'Choisir une sous-catégorie',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: subcategoryName.isNotEmpty
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: subcategoryName.isNotEmpty
                              ? Theme.of(context).textTheme.bodyLarge?.color
                              : Theme.of(context).hintColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Remove button
          if (enabled)
            Positioned(
              top: 1.h,
              right: 1.h,
              child: GestureDetector(
                onTap: () => _removeSubcategoryAmountCard(index),
                child: Container(
                  height: 3.h,
                  width: 3.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.surfaceDim,
                  ),
                  child: Center(
                    child: Icon(Icons.remove),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _onSubcategoryTap(
    Map<String, dynamic> item,
    int index,
  ) async {
    // Check if category is selected first
    if (_selectedCategory == null) {
      Fluttertoast.showToast(
        msg: 'Veuillez d\'abord sélectionner une catégorie',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    // Open subcategory selection dialog
    final selectedSubcategory = await SubcategorySelectionDialog.show(
      context,
      subcategories: _subcategories,
      categoryId: _selectedCategory?.id,
      selectedSubcategory: item['subcategory'] as Subcategory?,
    );

    if (selectedSubcategory != null && mounted) {
      // Update the item with selected subcategory
      setState(() {
        item['subcategory'] = selectedSubcategory;
        item['subcategoryName'] = selectedSubcategory.name ?? '';
        (item['subcategoryController'] as TextEditingController).text =
            selectedSubcategory.name ?? '';
      });

      // If this was a newly created subcategory, add it to the list
      if (selectedSubcategory.id == null) {
        setState(() {
          _subcategories.add(selectedSubcategory);
        });
      }
    }
  }

  Widget _buildAddSubcategoryAmountCard() {
    return GestureDetector(
      onTap: _addSubcategoryAmountCard,
      child: Container(
        margin: EdgeInsets.only(right: 3.w),
        height: 20.h,
        width: 25.w,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(4.w),
        ),
        child: Center(
          child: Icon(
            Icons.add,
            size: 24.sp,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }
}
