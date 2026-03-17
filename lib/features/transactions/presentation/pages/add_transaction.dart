import 'package:budgets/core/constants.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/core/ui/glass_flexible_space.dart';
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/features/categories/domain/models/subcategories.dart';
import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:budgets/features/transactions/presentation/modules/transaction_module.dart';
import 'package:budgets/features/transactions/presentation/pages/add_transaction/multiple_amounts_section.dart';
import 'package:budgets/features/transactions/presentation/pages/add_transaction/transaction_creation_initializer.dart';
import 'package:budgets/features/transactions/presentation/widgets/add_transaction/detailed_transaction_switch.dart';
import 'package:budgets/features/transactions/presentation/widgets/add_transaction/subcategory_amount_row.dart';
import 'package:budgets/features/transactions/presentation/widgets/transaction_date_picker_field.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_dropdown.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TransactionCreationPage extends ConsumerStatefulWidget {
  final String transactionType;
  final TransactionModel? transaction;

  const TransactionCreationPage(
      {super.key, this.transactionType = 'expense', this.transaction});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionCreationPageState();
}

class _TransactionCreationPageState
    extends ConsumerState<TransactionCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final _module = TransactionModule();
  final _listKey = GlobalKey<AnimatedListState>();
  final _designationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _montantController = TextEditingController();
  DateTime? _selectedDate;
  List<Category> _categories = [];
  Category? _selectedCategory;
  List<Subcategory> _subcategories = [];
  bool _isMultipleAmounts = false, _isLoading = false, _isInitializing = false;
  final List<Map<String, dynamic>> _subcategoryAmounts = [];

  TransactionType get transactionType =>
      TransactionType.fromValue(widget.transactionType) ??
      TransactionType.expense;
  bool get isEditMode => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    _isInitializing = isEditMode;
    if (isEditMode) {
      _descriptionController.text = widget.transaction!.description ?? '';
      _selectedDate = widget.transaction!.date;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final data = await TransactionCreationInitializer.initialize(
        ref: ref,
        isEditMode: isEditMode,
        transaction: widget.transaction,
        transactionType: transactionType,
        module: _module,
      );
      if (!mounted) return;
      setState(() {
        _categories = data.categories;
        _selectedCategory = data.selectedCategory;
        _subcategories = data.subcategories;
        _isMultipleAmounts = data.isMultipleAmounts;
        if (data.subcategoryAmounts.isNotEmpty)
          _subcategoryAmounts.addAll(data.subcategoryAmounts);
        if (data.amountText != null) _montantController.text = data.amountText!;
        _isInitializing = false;
      });
    });
  }

  @override
  void dispose() {
    _designationController.dispose();
    _descriptionController.dispose();
    _montantController.dispose();
    for (var item in _subcategoryAmounts) {
      item['subcategoryController']?.dispose();
      item['amountController']?.dispose();
    }
    super.dispose();
  }

  Widget _buildRemovedItem(Map<String, dynamic> item, Animation<double> anim) {
    return SizeTransition(
      sizeFactor: anim.drive(Tween(begin: 0.0, end: 1.0)
          .chain(CurveTween(curve: Curves.easeInOut))),
      child: ScaleTransition(
        scale: anim.drive(Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut))),
        child: FadeTransition(
            opacity: anim,
            child: SubcategoryAmountRow(
                item: item, subcategories: _subcategories, enabled: false)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
          body: Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor)));
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: _buildBody(),
      bottomNavigationBar: _buildAddButton(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: const GlassFlexibleSpace(),
      centerTitle: true,
      leading: IconButton(
          icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      title: Text(
        isEditMode
            ? (transactionType == TransactionType.income
                ? 'Modifier le revenu'
                : 'Modifier la dépense')
            : (transactionType == TransactionType.income
                ? 'Nouveau revenu'
                : 'Nouvelle dépense'),
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
      ),
    );
  }

  Widget _buildBody() {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SizedBox(
        height: double.infinity,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(left: 6.w, right: 6.w, top: 5.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),
                  if (_selectedCategory?.name !=
                      SystemCategories.savingsCategoryName) ...[
                    DetailedTransactionSwitch(
                      value: _isMultipleAmounts,
                      onChanged: (value) {
                        setState(() {
                          _isMultipleAmounts = value;
                          if (!value) {
                            _module.clearAllSubcategoryAmounts(
                                subcategoryAmounts: _subcategoryAmounts,
                                listKey: _listKey,
                                buildRemovedItem: (item, _, anim) =>
                                    _buildRemovedItem(item, anim),
                                onStateChanged: () => setState(() {}));
                          }
                        });
                      },
                    ),
                    SizedBox(height: 5.h),
                  ],
                  CustomDropdown(
                    title: Text('Catégorie',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 15.5.sp)),
                    hint: 'Choisissez une catégorie',
                    items: _categories,
                    selectedValue: _selectedCategory,
                    enabled: _selectedCategory?.name !=
                        SystemCategories.savingsCategoryName,
                    onChanged: (Category? category) async {
                      setState(() {
                        _selectedCategory = category;
                        _subcategories = [];
                      });
                      if (category?.id != null) {
                        try {
                          final subs = await _module.fetchSubcategories(
                              ref, category!.id!);
                          setState(() => _subcategories = subs);
                        } catch (_) {
                          setState(() => _subcategories = []);
                        }
                      }
                    },
                    validator: const <String, String>{"type": "required"},
                    showEmojis: true,
                  ),
                  SizedBox(height: 2.h),
                  if (!_isMultipleAmounts)
                    CustomTextField(
                      title: const SizedBox.shrink(),
                      hint: '0.00',
                      controller: _montantController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      fontSize: 24.sp,
                      height: 16.h,
                      width: double.infinity,
                      borderRadius: BorderRadius.circular(5.w),
                      validator: const <String, String>{"type": "required"},
                    )
                  else
                    MultipleAmountsSection(
                      subcategoryAmounts: _subcategoryAmounts,
                      subcategories: _subcategories,
                      listKey: _listKey,
                      module: _module,
                      onStateChanged: () => setState(() {}),
                      buildRemovedItem: _buildRemovedItem,
                      onSubcategoryChanged: (sub, item) => setState(() {}),
                      onSubcategoryTapWithoutCategory: () {
                        if (_selectedCategory == null)
                          showInfoToast(context,
                              "La catégorie doit être sélectionnée en premier");
                      },
                    ),
                  CustomTextField(
                    title: const SizedBox.shrink(),
                    hint: _selectedCategory?.name ==
                            SystemCategories.savingsCategoryName
                        ? _descriptionController.text
                        : 'Ajouter une description (optionnel)',
                    controller: _descriptionController,
                    keyboardType: TextInputType.text,
                    textAlign: TextAlign.center,
                    maxLines: null,
                    isReadOnly: _selectedCategory?.name ==
                        SystemCategories.savingsCategoryName,
                    borderRadius: BorderRadius.circular(5.w),
                  ),
                  if (isEditMode) ...[
                    SizedBox(height: 2.h),
                    TransactionDatePickerField(
                      selectedDate: _selectedDate,
                      isReadOnly: _selectedCategory?.name ==
                          SystemCategories.savingsCategoryName,
                      onDateSelected: (date) =>
                          setState(() => _selectedDate = date),
                    ),
                  ],
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.w),
      child: CustomButton(
        text: isEditMode ? 'Enregistrer' : 'Confirmer',
        backgroundColor: Theme.of(context).primaryColor,
        isLoading: _isLoading,
        onPressed: () async {
          setState(() => _isLoading = true);
          final result = await _module.submitTransaction(
            formKey: _formKey,
            selectedCategory: _selectedCategory,
            isMultipleAmounts: _isMultipleAmounts,
            subcategoryAmounts: _subcategoryAmounts,
            montantController: _montantController,
            descriptionController: _descriptionController,
            transactionType: transactionType,
            ref: ref,
            transactionId: widget.transaction?.id,
            transactionDate: isEditMode ? _selectedDate : null,
            originalTransaction: widget.transaction,
          );
          if (!mounted) return;
          setState(() => _isLoading = false);
          showAppToast(context, result.message,
              type: result.success ? AppToastType.success : AppToastType.error);
          if (result.success) context.pop();
        },
      ),
    );
  }
}
