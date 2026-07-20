import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/core/utils/animated_dialog.dart';
import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/features/categories/domain/models/subcategories.dart';
import 'package:budgets/features/categories/presentation/widgets/add_category_dialog.dart';
import 'package:budgets/features/categories/presentation/widgets/subcategory_selection_dialog.dart';
import 'package:budgets/features/transactions/presentation/modules/transaction_module.dart';
import 'package:budgets/features/transactions/presentation/widgets/add_transaction/category_pills_section.dart';
import 'package:budgets/features/transactions/presentation/widgets/add_transaction/dialog_chrome.dart';
import 'package:budgets/features/transactions/presentation/widgets/add_transaction/subcategory_pager_section.dart';
import 'package:budgets/widgets/animated_amount_field.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class AddTransactionDialog extends ConsumerStatefulWidget {
  final TransactionType transactionType;

  const AddTransactionDialog({super.key, required this.transactionType});

  static Future<bool?> show(BuildContext context,
      {required TransactionType transactionType}) {
    return showAnimatedDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          AddTransactionDialog(transactionType: transactionType),
    );
  }

  @override
  ConsumerState<AddTransactionDialog> createState() =>
      _AddTransactionDialogState();
}

class _AddTransactionDialogState extends ConsumerState<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _module = TransactionModule();
  final _montantController = AmountTextEditingController();
  final _descriptionController = TextEditingController();
  final _pageController = PageController(viewportFraction: 0.80);
  List<Category> _categories = [];
  Category? _selectedCategory;
  List<Subcategory> _subcategories = [];
  final List<Map<String, dynamic>> _subcategoryAmounts = [];
  final Set<int> _removingIndices = {};
  int? _newlyAddedIndex;
  bool _isLoading = false, _isInitializing = true, _isPerSubcategory = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _montantController.dispose();
    _descriptionController.dispose();
    _pageController.dispose();
    for (var item in _subcategoryAmounts) {
      item['subcategoryController']?.dispose();
      item['amountController']?.dispose();
    }
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final all = await _module.fetchCategories(ref);
      if (mounted) {
        setState(() {
          _categories = all
              .where((c) => c.transactionType == widget.transactionType)
              .toList();
          _isInitializing = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  void _togglePerSubcategory(bool value) => setState(() {
        _isPerSubcategory = value;
        if (!value) _clearSubcategoryAmounts();
      });

  void _clearSubcategoryAmounts() {
    for (var item in _subcategoryAmounts) {
      item['subcategoryController']?.dispose();
      item['amountController']?.dispose();
    }
    _subcategoryAmounts.clear();
    setState(() {});
  }

  void _addCard() {
    if (_selectedCategory == null) {
      showInfoToast(
          context, 'Veuillez d\'abord sélectionner une catégorie principale');
      return;
    }
    final idx = _subcategoryAmounts.length;
    _subcategoryAmounts.add(_module.createSubcategoryAmountItem());
    setState(() => _newlyAddedIndex = idx);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _newlyAddedIndex = null);
    });
  }

  void _removeCard(int index) {
    if (index >= _subcategoryAmounts.length || _removingIndices.contains(index))
      return;
    final target = index > 0 ? index - 1 : 0;
    setState(() => _removingIndices.add(index));
    Future.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      final removed = _subcategoryAmounts[index];
      removed['subcategoryController']?.dispose();
      removed['amountController']?.dispose();
      setState(() {
        _removingIndices.clear();
        _subcategoryAmounts.removeAt(index);
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients && _subcategoryAmounts.isNotEmpty) {
          _pageController.animateToPage(
              target.clamp(0, _subcategoryAmounts.length - 1),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic);
        }
      });
    });
  }

  Future<void> _onSubcategoryTap(Map<String, dynamic> item, int index) async {
    if (_selectedCategory == null) {
      showInfoToast(context, 'Veuillez d\'abord sélectionner une catégorie');
      return;
    }
    final selected = await SubcategorySelectionDialog.show(context,
        subcategories: _subcategories,
        categoryId: _selectedCategory?.id,
        selectedSubcategory: item['subcategory'] as Subcategory?);
    if (selected != null && mounted) {
      setState(() {
        item['subcategory'] = selected;
        item['subcategoryName'] = selected.name ?? '';
        (item['subcategoryController'] as TextEditingController).text =
            selected.name ?? '';
        if (selected.id == null) _subcategories.add(selected);
      });
    }
  }

  Future<void> _onCategoryTap(Category category) async {
    if (category.id == _selectedCategory?.id) return;
    if (_subcategoryAmounts.isNotEmpty) _clearSubcategoryAmounts();
    setState(() {
      _selectedCategory = category;
      _subcategories = [];
    });
    if (category.id != null) {
      try {
        final subs = await _module.fetchSubcategories(ref, category.id!);
        if (mounted) setState(() => _subcategories = subs);
      } catch (_) {
        if (mounted) setState(() => _subcategories = []);
      }
    }
  }

  Future<void> _submit() async {
    if (_selectedCategory == null) {
      showInfoToast(context, 'Veuillez sélectionner une catégorie');
      return;
    }
    if (_isPerSubcategory) {
      if (_subcategoryAmounts.isEmpty) {
        showInfoToast(context, 'Veuillez ajouter au moins une sous-catégorie');
        return;
      }
      if (!_module.validateSubcategoryAmounts(_subcategoryAmounts)) {
        showInfoToast(
            context, 'Veuillez remplir toutes les sous-catégories et montants');
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
    showAppToast(context, result.message,
        type: result.success ? AppToastType.success : AppToastType.error);
    if (result.success) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Dialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.w),
          side: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
        ),
        insetPadding:
            EdgeInsets.symmetric(horizontal: 5.w + 2.h, vertical: 5.h),
        child: _isInitializing
            ? SizedBox(
                height: 30.h,
                child: Center(
                    child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor)))
            : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(5.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DialogHeader(
                            type: widget.transactionType,
                            onClose: () => Navigator.of(context).pop(false)),
                        SizedBox(height: 2.h),
                        PerSubcategorySwitch(
                            value: _isPerSubcategory,
                            onChanged: _togglePerSubcategory),
                        SizedBox(height: 1.h),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, anim) => ScaleTransition(
                              scale: anim,
                              child: SizeTransition(
                                  sizeFactor: anim,
                                  axisAlignment: -1.0,
                                  child: child)),
                          child: _isPerSubcategory
                              ? const SizedBox.shrink(key: ValueKey('empty'))
                              : AnimatedAmountField(
                                  key: const ValueKey('amt'),
                                  controller: _montantController,
                                  hint: '0.00',
                                  fontSize: 25.sp,
                                  fillColor:
                                      Theme.of(context).colorScheme.surfaceDim,
                                  height: 15.h,
                                  width: double.infinity,
                                  borderRadius: BorderRadius.circular(3.w)),
                        ),
                        SizedBox(height: 2.h),
                        CategoryPillsSection(
                          categories: _categories,
                          selectedCategory: _selectedCategory,
                          isPerSubcategory: _isPerSubcategory,
                          onCategoryTap: _onCategoryTap,
                          onAddCategoryTap: (ctx) async {
                            final newCat = await AddCategoryDialog.show(ctx,
                                transactionType: widget.transactionType);
                            if (newCat != null) {
                              await _loadCategories();
                              final created = _categories.firstWhere(
                                  (c) => c.name == newCat.name,
                                  orElse: () => newCat);
                              setState(() => _selectedCategory = created);
                            }
                          },
                        ),
                        SizedBox(height: 2.h),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          switchInCurve: Curves.easeOutBack,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, anim) => ScaleTransition(
                              scale: anim,
                              alignment: Alignment.topCenter,
                              child: SizeTransition(
                                  sizeFactor: anim,
                                  axisAlignment: -1.0,
                                  child: FadeTransition(
                                      opacity: anim, child: child))),
                          child: _isPerSubcategory
                              ? Column(
                                  key: const ValueKey('subs'),
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                      SubcategoryPagerSection(
                                          subcategoryAmounts:
                                              _subcategoryAmounts,
                                          pageController: _pageController,
                                          removingIndices: _removingIndices,
                                          newlyAddedIndex: _newlyAddedIndex,
                                          onRemove: _removeCard,
                                          onAdd: _addCard,
                                          onSubcategoryTap: _onSubcategoryTap),
                                      SizedBox(height: 2.h),
                                    ])
                              : const SizedBox.shrink(key: ValueKey('noSubs')),
                        ),
                        CustomTextField(
                            title: Text('Description (optionnel)',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp)),
                            hint: 'Ajouter une description',
                            controller: _descriptionController,
                            keyboardType: TextInputType.text,
                            maxLines: 2,
                            borderRadius: BorderRadius.circular(3.w)),
                        SizedBox(height: 3.h),
                        CustomButton(
                            text: 'Confirmer',
                            backgroundColor: Theme.of(context).primaryColor,
                            onPressed: _submit,
                            isLoading: _isLoading),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

// Dialog widgets extracted to add_transaction/dialog_chrome.dart
