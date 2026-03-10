import 'package:budgets/core/currency/currency_provider.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:budgets/core/utils/animated_dialog.dart';
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/features/categories/domain/providers/category_provider.dart';
import 'package:budgets/features/categories/presentation/widgets/add_category_dialog.dart';
import 'package:budgets/features/planning/domain/models/budget_model.dart';
import 'package:budgets/features/planning/domain/providers/budget_provider.dart';
import 'package:budgets/widgets/animated_amount_field.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/skeleton/planning_skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// Dialog for adding or editing a budget.
class AddBudgetBottomSheet extends ConsumerStatefulWidget {
  final Budget? budget;

  const AddBudgetBottomSheet({super.key, this.budget});

  static Future<bool?> show(BuildContext context, {Budget? budget}) {
    return showAnimatedDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AddBudgetBottomSheet(budget: budget),
    );
  }

  @override
  ConsumerState<AddBudgetBottomSheet> createState() =>
      _AddBudgetBottomSheetState();
}

class _AddBudgetBottomSheetState extends ConsumerState<AddBudgetBottomSheet> {
  static const Map<String, String> _periodLabels = {
    'monthly': 'Mensuel',
    'weekly': 'Hebdomadaire',
    'bimonthly': 'Bimensuel',
    'biweekly': 'Toutes les 2 semaines',
    'yearly': 'Annuel',
  };

  final TextEditingController _amountController = TextEditingController();

  String? _selectedCategoryId;
  String _selectedPeriod = 'monthly';
  bool _isLoading = false;

  bool get _isEditing => widget.budget != null;

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      _selectedCategoryId = widget.budget!.category?.id;
      final initialPeriod = widget.budget!.period?.toLowerCase().trim();
      if (_periodLabels.containsKey(initialPeriod)) {
        _selectedPeriod = initialPeriod!;
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.budget?.amount == null) return;
      final currencyState = await ref.read(currencyControllerProvider.future);
      final rate = currencyState.rateFor(currencyState.code);
      final cleanAmount =
          widget.budget!.amount!.replaceAll(RegExp(r'[^\d]'), '');
      final amountMga = double.tryParse(cleanAmount) ?? 0;
      final displayAmount = convertFromMga(amountMga, rate);
      _amountController.text = formatAmountValue(displayAmount);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveBudget() async {
    if (_selectedCategoryId == null || _amountController.text.trim().isEmpty) {
      showInfoToast(context, 'Veuillez remplir tous les champs');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currencyState = await ref.read(currencyControllerProvider.future);
      final rate = currencyState.rateFor(currencyState.code);
      final displayAmount = parseAmountInput(_amountController.text);
      final mgaAmount = convertToMga(displayAmount, rate).round();

      final budget = Budget(
        id: widget.budget?.id,
        category: Category(id: _selectedCategoryId),
        amount: mgaAmount.toString(),
        amountSpent: widget.budget?.amountSpent ?? '0',
        period: _selectedPeriod,
      );

      if (_isEditing) {
        await ref.read(budgetsProvider.notifier).updateSomeBudget(budget);
      } else {
        await ref.read(budgetsProvider.notifier).addSomeBudget(budget);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        showErrorToast(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onAddCategoryTap() async {
    final newCategory = await AddCategoryDialog.show(
      context,
      transactionType: TransactionType.expense,
    );

    if (newCategory == null || !mounted) return;

    final updatedCategories = await ref.read(categoriesProvider.future);
    Category? createdCategory;

    for (final category in updatedCategories) {
      if (category.name == newCategory.name) {
        createdCategory = category;
        break;
      }
    }

    if (createdCategory != null) {
      setState(() {
        _selectedCategoryId = createdCategory!.id;
      });
    }
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
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(5.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _isEditing ? 'Modifier le budget' : 'Nouveau budget',
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
                        onPressed: () => Navigator.of(context).pop(false),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                AnimatedAmountField(
                  controller: _amountController,
                  hint: '0.00',
                  fontSize: 28.sp,
                  fillColor: Theme.of(context).colorScheme.surfaceDim,
                  height: 15.h,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(3.w),
                ),
                SizedBox(height: 2.h),
                _buildCategorySection(),
                SizedBox(height: 2.h),
                _buildPeriodDropdown(),
                SizedBox(height: 3.h),
                CustomButton(
                  text: _isEditing ? 'Modifier' : 'Ajouter',
                  onPressed: _saveBudget,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catégorie',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15.5.sp,
          ),
        ),
        SizedBox(height: 1.h),
        categoriesAsync.when(
          data: _buildCategoryPills,
          loading: () => const CategoryChipsSkeleton(),
          error: (e, _) => Text('Erreur: $e'),
        ),
      ],
    );
  }

  Widget _buildCategoryPills(List<Category> categories) {
    final budgetsAsync = ref.watch(budgetsProvider);
    final existingBudgetCategoryIds = budgetsAsync.asData?.value
            .where(
              (budget) =>
                  budget.category?.id != null && budget.id != widget.budget?.id,
            )
            .map((budget) => budget.category!.id!)
            .toSet() ??
        <String>{};

    final expenseCategories = categories.where((category) {
      final isExpense = category.transactionType?.value == 'expense';
      final isAlreadyBudgeted = existingBudgetCategoryIds.contains(category.id);
      return isExpense && !isAlreadyBudgeted;
    }).toList();

    return SizedBox(
      height: 5.2.h,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          ...expenseCategories.map(_buildCategoryPill),
          _buildAddCategoryPill(),
        ],
      ),
    );
  }

  Widget _buildCategoryPill(Category category) {
    final isSelected = _selectedCategoryId == category.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategoryId = category.id;
        });
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
              category.emoji ?? '📁',
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
      onTap: _onAddCategoryTap,
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

  Widget _buildPeriodDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Période du budget',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: 1.h),
        DropdownButtonFormField<String>(
          initialValue: _selectedPeriod,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardColor,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 1.6.h,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3.w),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
          borderRadius: BorderRadius.circular(3.w),
          dropdownColor: Theme.of(context).cardColor,
          iconEnabledColor: Theme.of(context).hintColor,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 15.sp,
          ),
          items: _periodLabels.entries
              .map(
                (entry) => DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() {
              _selectedPeriod = value;
            });
          },
        ),
      ],
    );
  }
}
