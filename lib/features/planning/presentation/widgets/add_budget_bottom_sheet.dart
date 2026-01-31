import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/features/categories/domain/providers/category_provider.dart';
import 'package:budgets/features/planning/domain/models/budget_model.dart';
import 'package:budgets/features/planning/domain/providers/budget_provider.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:budgets/widgets/skeleton/planning_skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:budgets/core/utils/amount_input_formatter.dart';
import 'package:flutter/services.dart';

/// Bottom sheet for adding or editing a budget
class AddBudgetBottomSheet extends ConsumerStatefulWidget {
  final Budget? budget; // Pass existing budget for editing

  const AddBudgetBottomSheet({super.key, this.budget});

  @override
  ConsumerState<AddBudgetBottomSheet> createState() =>
      _AddBudgetBottomSheetState();
}

class _AddBudgetBottomSheetState extends ConsumerState<AddBudgetBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  String? _selectedCategoryId;
  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = false;

  bool get _isEditing => widget.budget != null;

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      if (widget.budget!.amount != null) {
        final cleanAmount = widget.budget!.amount!.replaceAll(RegExp(r'[^\d]'), '');
        if (cleanAmount.isNotEmpty) {
          final value = int.parse(cleanAmount);
          final formatter = NumberFormat("#,##0", "en_US");
          _amountController.text = formatter.format(value);
        }
      }
      _selectedCategoryId = widget.budget!.category?.id;
      if (widget.budget!.createdAt != null) {
        _selectedMonth = widget.budget!.createdAt!;
      }
    }
    _monthController.text =
        DateFormat('MMMM yyyy', 'fr_FR').format(_selectedMonth);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  Future<void> _selectMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = picked;
        _monthController.text =
            DateFormat('MMMM yyyy', 'fr_FR').format(_selectedMonth);
      });
    }
  }

  Future<void> _saveBudget() async {
    if (_selectedCategoryId == null || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final budget = Budget(
        id: widget.budget?.id,
        category: _selectedCategoryId != null
            ? Category(id: _selectedCategoryId)
            : null,
        amount: _amountController.text,
        amountSpent: widget.budget?.amountSpent ?? '0',
      );

      if (_isEditing) {
        await ref.read(budgetsProvider.notifier).updateSomeBudget(budget);
      } else {
        await ref.read(budgetsProvider.notifier).addSomeBudget(budget);
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8.w)),
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: _buildBody(scrollController),
            bottomNavigationBar: _buildBottomBar(),
          ),
        );
      },
    );
  }

  Widget _buildBody(ScrollController scrollController) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        controller: scrollController,
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHandle(),
            SizedBox(height: 2.h),
            _buildAmountInput(),
            SizedBox(height: 4.h),
            _buildCategorySection(),
            SizedBox(height: 3.h),
            _buildMonthPicker(),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 12.w,
        height: 0.5.h,
        margin: EdgeInsets.only(bottom: 1.h),
        decoration: BoxDecoration(
          color: Theme.of(context).hintColor.withAlpha(75),
          borderRadius: BorderRadius.circular(2.w),
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Center(
      child: IntrinsicWidth(
        child: TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          inputFormatters: [
            AmountInputFormatter(),
          ],
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w300,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          decoration: InputDecoration(
            hintText: '0.00',
            hintStyle: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w300,
              color: Theme.of(context).hintColor.withAlpha(128),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
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
          'Categories',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: 1.5.h),
        categoriesAsync.when(
          data: (categories) => _buildCategoryChips(categories),
          loading: () => const CategoryChipsSkeleton(),
          error: (e, _) => Text('Erreur: $e'),
        ),
      ],
    );
  }

  Widget _buildCategoryChips(List<Category> categories) {
    // Filter expense categories only for budgets
    final expenseCategories =
        categories.where((c) => c.transactionType?.value == 'expense').toList();

    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: expenseCategories.map((category) {
        final isSelected = _selectedCategoryId == category.id;
        return GestureDetector(
          onTap: () => setState(() => _selectedCategoryId = category.id),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.2.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              category.name ?? '',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.black
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMonthPicker() {
    return CustomTextField(
      title: Text(
        'Budget pour',
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      controller: _monthController,
      isReadOnly: true,
      onTap: _selectMonth,
      suffixIcon: Icon(
        Icons.calendar_today,
        size: 18.sp,
        color: Theme.of(context).hintColor,
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.fromLTRB(6.w, 1.h, 6.w, 3.h),
      child: SafeArea(
        child: CustomButton(
          text: _isEditing ? 'Modifier' : 'Ajouter',
          onPressed: _saveBudget,
          isLoading: _isLoading,
        ),
      ),
    );
  }
}
