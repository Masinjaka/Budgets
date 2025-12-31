import 'package:budgets/core/ui/glass_flexible_space.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/features/transactions/domain/model/transaction_model.dart';
import 'package:budgets/features/transactions/presentation/modules/transaction_module.dart';
import 'package:budgets/features/transactions/presentation/widgets/add_transaction/detailed_transaction_switch.dart';
import 'package:budgets/features/transactions/presentation/widgets/add_transaction/subcategory_amount_row.dart';
import 'package:budgets/widgets/custom_border_painter.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:budgets/widgets/custom_dropdown.dart';
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/features/categories/domain/models/subcategories.dart';
import 'package:budgets/features/categories/domain/providers/subcategory_expenses_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class TransactionCreationPage extends ConsumerStatefulWidget {
  final String transactionType;
  final TransactionModel? transaction; // Optional transaction for edit mode

  const TransactionCreationPage({
    super.key,
    this.transactionType = 'expense',
    this.transaction,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransactionCreationPageState();
}

class _TransactionCreationPageState
    extends ConsumerState<TransactionCreationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _isLoading = false;
  final TransactionModule _module = TransactionModule();

  // Get transaction type from widget
  TransactionType get transactionType =>
      TransactionType.fromValue(widget.transactionType) ??
      TransactionType.expense;

  // Check if in edit mode
  bool get isEditMode => widget.transaction != null;

  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _montantController = TextEditingController();
  DateTime? _selectedDate;

  List<Category> _categories = [];
  Category? _selectedCategory;
  List<Subcategory> _subcategories = [];
  bool _isMultipleAmounts = false;
  final List<Map<String, dynamic>> _subcategoryAmounts = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();

    _isInitializing = isEditMode;

    // Pre-fill form if in edit mode
    if (isEditMode) {
      _descriptionController.text = widget.transaction!.description ?? '';
      _selectedDate = widget.transaction!.date;
    }

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        final allCategories = await _module.fetchCategories(ref);
        // Filter categories by transaction type
        final filteredCategories = allCategories
            .where((category) => category.transactionType == transactionType)
            .toList();

        // Local variables for state update
        List<Category> newCategories = filteredCategories;
        Category? newSelectedCategory;
        List<Subcategory> newSubcategories = [];
        bool newIsMultipleAmounts = false;

        // Pre-select category if in edit mode
        if (isEditMode && widget.transaction!.category != null) {
          newSelectedCategory = filteredCategories.firstWhere(
            (cat) => cat.id == widget.transaction!.category!.id,
            orElse: () => filteredCategories.first,
          );
        }

        // In edit mode, check if transaction has subcategories
        if (isEditMode && widget.transaction!.id != null) {
          try {
            // Fetch subcategory expenses for this transaction
            final subcategoryExpenses = await ref.read(
              subcategoryExpensesProvider(widget.transaction!.id!).future,
            );

            // If subcategories exist, activate detailed transaction mode
            if (subcategoryExpenses.isNotEmpty) {
              // Fetch subcategories for the selected category
              if (newSelectedCategory?.id != null) {
                newSubcategories = await _module.fetchSubcategories(
                  ref,
                  newSelectedCategory!.id!,
                );
              }

              newIsMultipleAmounts = true;

              // Clear any existing entries
              _subcategoryAmounts.clear();

              // Add each subcategory expense to the list
              for (var subExpense in subcategoryExpenses) {
                final subcategoryController = TextEditingController(
                  text: subExpense.subcategory?.name ?? '',
                );
                final amountController = TextEditingController(
                  text: subExpense.amount?.toString() ?? '',
                );

                // Find matching subcategory instance from the fetched list
                Subcategory? matchedSubcategory;
                if (subExpense.subcategory?.id != null &&
                    newSubcategories.isNotEmpty) {
                  try {
                    matchedSubcategory = newSubcategories.firstWhere(
                      (s) => s.id == subExpense.subcategory!.id,
                    );
                  } catch (_) {
                    // Not found in current category list
                  }
                }

                // Fallback to the expense's subcategory if match failed
                matchedSubcategory ??= subExpense.subcategory;

                final item = {
                  'subcategoryController': subcategoryController,
                  'amountController': amountController,
                  'subcategoryName': subExpense.subcategory?.name ?? '',
                  'subcategoryId': subExpense.subcategory?.id,
                  'subcategory': matchedSubcategory,
                };

                _subcategoryAmounts.add(item);
              }

              debugPrint(
                "✅ Pre-filled ${subcategoryExpenses.length} subcategory expenses",
              );
            } else {
              // No subcategories, use regular amount field
              _montantController.text =
                  widget.transaction!.amount?.toString() ?? '';
            }
          } catch (e) {
            debugPrint("❌ Error fetching subcategory expenses: $e");
            // Fallback to regular amount field
            _montantController.text =
                widget.transaction!.amount?.toString() ?? '';
          }
        } else if (!isEditMode) {
          // Not in edit mode, keep amount field empty for new transactions
        } else {
          // Edit mode but no transaction ID, use the total amount
          _montantController.text =
              widget.transaction!.amount?.toString() ?? '';
        }

        // Apply all changes
        if (mounted) {
          setState(() {
            _categories = newCategories;
            _selectedCategory = newSelectedCategory;
            _subcategories = newSubcategories;
            _isMultipleAmounts = newIsMultipleAmounts;
            _isInitializing = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _designationController.dispose();
    _descriptionController.dispose();
    _montantController.dispose();

    // Dispose subcategory controllers
    for (var item in _subcategoryAmounts) {
      item['subcategoryController']?.dispose();
      item['amountController']?.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }
    // Always use dark mode
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: _buildForm(),
      bottomNavigationBar: _buildAddButton(),
    );
  }

  GestureDetector _buildForm() {
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
                  SizedBox(height: 10.h), // Top padding for glass effect
                  // Switch for multiple amounts
                  DetailedTransactionSwitch(
                    value: _isMultipleAmounts,
                    onChanged: (value) {
                      setState(() {
                        _isMultipleAmounts = value;
                        if (!value) {
                          // Clear all items with animation
                          _module.clearAllSubcategoryAmounts(
                            subcategoryAmounts: _subcategoryAmounts,
                            listKey: _listKey,
                            buildRemovedItem: (item, index, animation) =>
                                _buildRemovedSubcategoryItem(item, animation),
                            onStateChanged: () => setState(() {}),
                          );
                        }
                      });
                    },
                  ),
                  SizedBox(height: 5.h),
                  CustomDropdown(
                    title: Text(
                      'Catégorie',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5.sp,
                      ),
                    ),
                    hint: 'Choisissez une catégorie',
                    items: _categories,
                    selectedValue: _selectedCategory,
                    onChanged: (Category? category) async {
                      setState(() {
                        _selectedCategory = category;
                        _subcategories =
                            []; // Clear subcategories when category changes
                      });

                      // Fetch subcategories when a category is selected using the module method
                      if (category != null && category.id != null) {
                        try {
                          final subcategories = await _module
                              .fetchSubcategories(ref, category.id!);
                          setState(() {
                            _subcategories = subcategories;
                          });
                          debugPrint("SUBCATEGORIES: ${subcategories.length}");
                        } catch (e) {
                          debugPrint("Error fetching subcategories: $e");
                          setState(() {
                            _subcategories = []; // Set empty list on error
                          });
                        }
                      }
                    },
                    validator: const <String, String>{"type": "required"},
                    showEmojis: true,
                  ),
                  SizedBox(height: 2.h),
                  // Conditional content based on switch
                  if (!_isMultipleAmounts)
                    CustomTextField(
                      title: const SizedBox.shrink(),
                      // Text(
                      //   'Montant',
                      //   textAlign: TextAlign.left,
                      //   style: TextStyle(
                      //     fontWeight: FontWeight.w900,
                      //     fontSize: 15.5.sp,
                      //   ),
                      // ),
                      hint: '0.00',
                      controller: _montantController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      fontSize: 24.sp,
                      height: 16.h, // Increase vertical padding
                      width: double.infinity,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5.w),
                        topRight: Radius.circular(5.w),
                        bottomLeft: Radius.circular(5.w),
                        bottomRight: Radius.circular(5.w),
                      ),
                      validator: const <String, String>{"type": "required"},
                    )
                  else
                    _buildMultipleAmountsSection(),
                  CustomTextField(
                    title: const SizedBox.shrink(),
                    hint: 'Ajouter une description (optionnel)',
                    controller: _descriptionController,
                    keyboardType: TextInputType.text,
                    textAlign: TextAlign.center,
                    maxLines: null,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5.w),
                      topRight: Radius.circular(5.w),
                      bottomLeft: Radius.circular(5.w),
                      bottomRight: Radius.circular(5.w),
                    ),
                  ),
                  // Date picker field - only visible in edit mode
                  if (isEditMode) ...[
                    SizedBox(height: 2.h),
                    GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(5.w),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Date',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  _selectedDate != null
                                      ? DateFormat.yMMMd('fr_FR')
                                          .format(_selectedDate!)
                                      : 'Sélectionner une date',
                                  style: TextStyle(
                                    color: Theme.of(context).hintColor,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Icon(
                                  Icons.calendar_today,
                                  color: Theme.of(context).primaryColor,
                                  size: 18.sp,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildMultipleAmountsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Montants par sous-catégories',
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 15.5.sp,
          ),
        ),
        SizedBox(height: 1.5.h),

        // List of subcategory amounts
        AnimatedList(
          key: _listKey,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          initialItemCount: _subcategoryAmounts
              .length, // Start with current length to ensure all items animate
          itemBuilder: (context, index, animation) {
            if (index >= _subcategoryAmounts.length) {
              return const SizedBox.shrink();
            }

            return _buildAnimatedSubcategoryItem(
              _subcategoryAmounts[index],
              index,
              animation,
            );
          },
        ),

        // Add button with dashed border effect
        GestureDetector(
          onTap: () => _module.addSubcategoryAmount(
            subcategoryAmounts: _subcategoryAmounts,
            listKey: _listKey,
            onStateChanged: () => setState(() {}),
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 1.5.w),
            child: CustomPaint(
              painter: DashedBorderPainter(
                color: Theme.of(context).dividerColor.withAlpha(128),
                strokeWidth: 1.0,
                borderRadius: 5.w,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.5.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: Theme.of(context).iconTheme.color,
                      size: 16.sp,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Ajouter une sous-catégorie',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: const GlassFlexibleSpace(),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: Text(
        isEditMode
            ? (transactionType == TransactionType.income
                ? 'Modifier le revenu'
                : 'Modifier la dépense')
            : (transactionType == TransactionType.income
                ? 'Nouveau revenu'
                : 'Nouvelle dépense'),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.sp,
        ),
      ),
    );
  }

  Padding _buildAddButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.w),
      child: CustomButton(
        text: isEditMode ? 'Enregistrer' : 'Confirmer',
        backgroundColor: Theme.of(context).primaryColor,
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
          );

          if (!mounted) {
            return;
          }

          setState(() => _isLoading = false);

          // Show result message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: result.success ? Colors.green : Colors.red,
            ),
          );

          // Navigate back on success
          if (result.success) {
            context.pop();
          }
        },
        isLoading: _isLoading,
      ),
    );
  }

  Widget _buildAnimatedSubcategoryItem(
    Map<String, dynamic> item,
    int index,
    Animation<double> animation,
  ) {
    return SlideTransition(
      position: animation.drive(
        Tween<Offset>(
          begin: const Offset(0, -1), // Drop from top
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
      ),
      child: FadeTransition(
        opacity: animation,
        child: SubcategoryAmountRow(
          item: item,
          subcategories: _subcategories,
          onAmountChanged: (value) {
            final subcategoryName = item['subcategoryName'] as String?;
            debugPrint("💰 AMOUNT CHANGED:");
            debugPrint("  - Subcategory: ${subcategoryName ?? 'Not selected'}");
            debugPrint("  - Amount: $value");
            debugPrint("  - Item index: ${_subcategoryAmounts.indexOf(item)}");
          },
          onSubcategoryChanged: (Subcategory? subcategory) {
            if (subcategory != null) {
              (item['subcategoryController'] as TextEditingController).text =
                  subcategory.name ?? '';
              item['subcategoryName'] = subcategory.name ?? '';
              debugPrint("🔥 SUBCATEGORY SELECTED:");
              debugPrint("  - ID: ${subcategory.id}");
              debugPrint("  - Name: ${subcategory.name}");
              debugPrint("  - Category ID: ${subcategory.categoryId}");
              debugPrint(
                  "  - Stored in item['subcategoryName']: ${item['subcategoryName']}");
              setState(() {});
            }
          },
          onSubcategoryTap: () {
            if (_selectedCategory == null) {
              Fluttertoast.showToast(
                msg: "La catégorie doit être sélectionnée en premier",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 2,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            }
          },
          onRemove: () => _module.removeSubcategoryAmount(
            index: index,
            subcategoryAmounts: _subcategoryAmounts,
            listKey: _listKey,
            buildRemovedItem: (item, index, animation) =>
                _buildRemovedSubcategoryItem(item, animation),
            onStateChanged: () => setState(() {}),
          ),
          enabled: true,
        ),
      ),
    );
  }

  Widget _buildRemovedSubcategoryItem(
    Map<String, dynamic> item,
    Animation<double> animation,
  ) {
    return SizeTransition(
      sizeFactor: animation.drive(
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
      ),
      child: ScaleTransition(
        scale: animation.drive(
          Tween<double>(
            begin: 0.0, // Start scaled down
            end: 1.0, // End at full size
          ).chain(CurveTween(curve: Curves.easeOut)),
        ),
        child: FadeTransition(
          opacity: animation,
          child: SubcategoryAmountRow(
            item: item,
            subcategories: _subcategories,
            enabled: false,
          ),
        ),
      ),
    );
  }
}
