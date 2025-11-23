import 'package:budgets/core/theme.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/features/transactions/presentation/modules/transaction_module.dart';
import 'package:budgets/widgets/custom_border_painter.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:budgets/widgets/custom_dropdown.dart';
import 'package:budgets/widgets/custom_subcategory_dropdown.dart';
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/features/categories/domain/models/subcategories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TransactionCreationPage extends ConsumerStatefulWidget {
  final String transactionType;

  const TransactionCreationPage({
    super.key,
    this.transactionType = 'expense',
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

  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _montantController = TextEditingController();

  List<Category> _categories = [];
  Category? _selectedCategory;
  List<Subcategory> _subcategories = [];
  bool _isMultipleAmounts = false;
  final List<Map<String, dynamic>> _subcategoryAmounts = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        final allCategories = await _module.fetchCategories(ref);
        // Filter categories by transaction type
        final filteredCategories = allCategories
            .where((category) => category.transactionType == transactionType)
            .toList();

        setState(() {
          _categories = filteredCategories;
        });
        debugPrint(
            "CATEGORIES FOR ${transactionType.value}: ${filteredCategories.length}");
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
    // Always use dark mode
    return Scaffold(
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
            padding: EdgeInsets.only(left: 2.w, right: 2.w, top: 5.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  SizedBox(height: 3.h),
                  CustomTextField(
                    title: Text(
                      'Description',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5.sp,
                      ),
                    ),
                    hint: 'Laoka atoandro sy hariva',
                    controller: _descriptionController,
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 5.h),

                  // Switch for multiple amounts
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryDark,
                      borderRadius: BorderRadius.circular(2.w),
                      border: Border.all(
                        color: AppTheme.borderColorDark,
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mode de saisie',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.sp,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                _isMultipleAmounts
                                    ? 'Montants multiples par sous-catégories'
                                    : 'Montant général pour la catégorie',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color:
                                      AppTheme.textDark.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.borderColorDark,
                              width: 1.5,
                            ),
                          ),
                          child: Switch(
                            value: _isMultipleAmounts,
                            onChanged: (value) {
                              setState(() {
                                _isMultipleAmounts = value;
                                if (!value) {
                                  // Clear all items with animation
                                  _module.clearAllSubcategoryAmounts(
                                    subcategoryAmounts: _subcategoryAmounts,
                                    listKey: _listKey,
                                    buildRemovedItem:
                                        _buildRemovedSubcategoryItem,
                                    onStateChanged: () => setState(() {}),
                                  );
                                }
                              });
                            },
                            // activeThumbColor: Colors.white,
                            activeTrackColor: AppTheme.textDark,
                            inactiveThumbColor: AppTheme.secondaryDark,
                            inactiveTrackColor: AppTheme.borderColorDark,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 3.h),

                  // Conditional content based on switch
                  if (!_isMultipleAmounts)
                    CustomTextField(
                      title: Text(
                        'Montant',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15.5.sp,
                        ),
                      ),
                      hint: '10000',
                      controller: _montantController,
                      keyboardType: TextInputType.number,
                      validator: const <String, String>{"type": "required"},
                    )
                  else
                    _buildMultipleAmountsSection(),

                  SizedBox(height: 1.5.h),
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
          physics: const NeverScrollableScrollPhysics(),
          initialItemCount: 0, // Start with 0 to ensure all items animate
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
                color: (AppTheme.textDark).withValues(alpha: 0.3),
                strokeWidth: 1.0,
                borderRadius: 2.w,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.5.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      color: AppTheme.textDark,
                      size: 16.sp,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Ajouter une sous-catégorie',
                      style: TextStyle(
                        color: AppTheme.textDark,
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
      automaticallyImplyLeading: false,
      title: Text(
        transactionType == TransactionType.income
            ? 'Nouveau revenu'
            : 'Nouvelle dépense',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 18.sp,
        ),
      ),
      actions: [
        IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.close,
              size: 21.sp,
            )),
      ],
    );
  }

  Padding _buildAddButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 5.w),
      child: CustomButton(
        text: 'Confirmer',
        backgroundColor: AppTheme.primaryGreen,
        onPressed: () async {
          setState(() => _isLoading = true);

          if (!_formKey.currentState!.validate()) {
            setState(() => _isLoading = false);
            return;
          }

          if (_selectedCategory == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tu dois choisir une catégorie'),
              ),
            );
            setState(() => _isLoading = false);
            return;
          }

          // Handle different submission modes
          if (_isMultipleAmounts) {
            // Validate subcategory amounts
            if (!_module.validateSubcategoryAmounts(_subcategoryAmounts)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Veuillez remplir toutes les sous-catégories et montants'),
                ),
              );
              setState(() => _isLoading = false);
              return;
            }

            // Build subcategory amounts map
            final subcategoryMap =
                _module.buildSubcategoryAmountsMap(_subcategoryAmounts);
            final totalAmount =
                _module.calculateTotalAmount(_subcategoryAmounts);

            debugPrint("🗺️ FINAL SUBCATEGORY MAP: $subcategoryMap");
            debugPrint("💰 TOTAL AMOUNT: $totalAmount");

            debugPrint("Calling Supabase RPC with:");
            debugPrint("Total Amount: $totalAmount");
            debugPrint("Description: ${_descriptionController.text.trim()}");
            debugPrint("Category: ${_selectedCategory!.name ?? ''}");
            debugPrint("Subcategory Map: $subcategoryMap");

            final transactionAdded = await _module.addTransaction(
              amount: totalAmount.toString(),
              description: _descriptionController.text.trim(),
              categoryName: _selectedCategory!.name ?? '',
              subcategoryAmounts: subcategoryMap,
              transactionType: transactionType,
              formKey: _formKey,
              ref: ref,
              // context: context, // Removed context
            );

            if (!mounted) {
              return; // Ensure widget is still mounted before UI interactions
            }

            if (transactionAdded) {
              // For now, show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${transactionType.displayName} avec sous-catégories ajoutée: ${totalAmount.toStringAsFixed(2)}'),
                  backgroundColor: Colors.green,
                ),
              );
              context.pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erreur lors de l\'ajout de la transaction.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else {
            // Single amount mode - use existing logic
            final transactionAdded = await _module.addTransaction(
              amount: _montantController.text.trim(),
              description: _descriptionController.text.trim(),
              categoryName: _selectedCategory!.name ?? '',
              subcategoryAmounts: null,
              transactionType: transactionType,
              formKey: _formKey,
              ref: ref,
              // context: context, // Removed context
            );
            if (!mounted) {
              return;
            }

            if (transactionAdded) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${transactionType.displayName} ajoutée: ${_montantController.text.trim()}'),
                  backgroundColor: Colors.green,
                ),
              );
              context.pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erreur lors de l\'ajout de la transaction.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }

          setState(() => _isLoading = false);
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
        child: Container(
          margin: EdgeInsets.only(bottom: 2.h),
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.w),
          decoration: BoxDecoration(
            color: AppTheme.secondaryDark.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(2.w),
            border: Border.all(
              color: AppTheme.borderColorDark,
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildSubcategoryField(item),
              ),
              Container(
                height: 4.h,
                width: 1,
                color: (AppTheme.borderColorDark).withValues(alpha: 0.5),
                margin: EdgeInsets.symmetric(horizontal: 2.w),
              ),
              Expanded(
                child: TextFormField(
                  controller:
                      item['amountController'] as TextEditingController?,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final subcategoryName = item['subcategoryName'] as String?;
                    debugPrint("💰 AMOUNT CHANGED:");
                    debugPrint(
                        "  - Subcategory: ${subcategoryName ?? 'Not selected'}");
                    debugPrint("  - Amount: $value");
                    debugPrint(
                        "  - Item index: ${_subcategoryAmounts.indexOf(item)}");
                  },
                  decoration: InputDecoration(
                    hintText: 'Montant',
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  ),
                  style: TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              GestureDetector(
                onTap: () => _module.removeSubcategoryAmount(
                  index: index,
                  subcategoryAmounts: _subcategoryAmounts,
                  listKey: _listKey,
                  buildRemovedItem: _buildRemovedSubcategoryItem,
                  onStateChanged: () => setState(() {}),
                ),
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(1.w),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                  ),
                  child: Icon(
                    Icons.remove,
                    color: Colors.red,
                    size: 16.sp,
                  ),
                ),
              ),
            ],
          ),
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
          child: Container(
            margin: EdgeInsets.only(bottom: 2.h),
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.w),
            decoration: BoxDecoration(
              color: AppTheme.secondaryDark.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2.w),
              border: Border.all(
                color: AppTheme.borderColorDark,
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CustomSubcategoryDropdown(
                    title: const SizedBox.shrink(),
                    hint: 'Tapez ou sélectionnez une sous-catégorie',
                    items: _subcategories,
                    selectedValue: item['subcategory'] as Subcategory?,
                    onChanged: null, // Disabled for removed items
                    enabled: false,
                  ),
                ),
                Container(
                  height: 4.h,
                  width: 1,
                  color: AppTheme.borderColorDark.withValues(alpha: 0.5),
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                ),
                Expanded(
                  child: TextFormField(
                    controller:
                        item['amountController'] as TextEditingController?,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Montant',
                      isDense: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                    ),
                    style: TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(1.w),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                  ),
                  child: Icon(
                    Icons.remove,
                    color: Colors.red,
                    size: 16.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubcategoryField(Map<String, dynamic> item) {
    return CustomSubcategoryDropdown(
      title: const SizedBox.shrink(),
      hint: 'Tapez ou sélectionnez une sous-catégorie',
      items: _subcategories,
      selectedValue: null, // We'll handle selection differently
      onChanged: (Subcategory? subcategory) {
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
      enabled: true,
    );
  }
}
