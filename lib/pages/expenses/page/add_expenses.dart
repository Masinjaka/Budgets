import 'package:budgets/core/theme.dart';
import 'package:budgets/pages/expenses/module/expense_module.dart';
import 'package:budgets/provider/app_theme_provider.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:budgets/widgets/custom_dropdown.dart';
import 'package:budgets/model/category_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ExpenseCreationPage extends ConsumerStatefulWidget {
  const ExpenseCreationPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ExpenseCreationPageState();
}

class _ExpenseCreationPageState extends ConsumerState<ExpenseCreationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool _isLoading = false;
  bool _isDarkMode = false;
  final ExpenseModule _module = ExpenseModule();

  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _montantController = TextEditingController();

  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _isMultipleAmounts = false;
  List<Map<String, dynamic>> _subcategoryAmounts = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        final categories = await _module.fetchCategories(ref);
        setState(() {
          _categories = categories;
        });
        debugPrint("CATEGORIES: ${categories.length}");
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
    final globalTheme = ref.watch(globalThemeProvider);

    _isDarkMode = globalTheme == Brightness.dark;
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
            padding: EdgeInsets.only(left: 7.w, right: 7.w, top: 5.h),
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
                    onChanged: (Category? category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    validator: const <String, String>{"type": "required"},
                    showEmojis: true,
                  ),
                  SizedBox(height: 1.5.h),
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
                  SizedBox(height: 1.5.h),

                  // Switch for multiple amounts
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: _isDarkMode
                          ? AppTheme.secondaryDark
                          : Colors.grey[50],
                      borderRadius: BorderRadius.circular(2.w),
                      border: Border.all(
                        color: _isDarkMode
                            ? AppTheme.borderColorDark
                            : Colors.grey[300]!,
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
                                  color: _isDarkMode
                                      ? AppTheme.textDark
                                      : Colors.black87,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                _isMultipleAmounts
                                    ? 'Montants multiples par sous-catégories'
                                    : 'Montant général pour la catégorie',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: (_isDarkMode
                                          ? AppTheme.textDark
                                          : Colors.black87)
                                      .withOpacity(0.7),
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
                              color: _isDarkMode
                                  ? AppTheme.borderColorDark
                                  : Colors.grey[400]!,
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
                                  _clearAllSubcategoryAmounts();
                                }
                              });
                            },
                            activeColor: Colors.white,
                            activeTrackColor: _isDarkMode
                                ? AppTheme.textDark
                                : Colors.black87,
                            inactiveThumbColor: _isDarkMode
                                ? AppTheme.secondaryDark
                                : Colors.white,
                            inactiveTrackColor: _isDarkMode
                                ? AppTheme.borderColorDark
                                : Colors.grey[300],
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 1.5.h),

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
        SizedBox(height: 1.h),

        // List of subcategory amounts
        AnimatedList(
          key: _listKey,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          initialItemCount: 0, // Start with 0 to ensure all items animate
          itemBuilder: (context, index, animation) {
            if (index >= _subcategoryAmounts.length)
              return const SizedBox.shrink();

            return _buildAnimatedSubcategoryItem(
              _subcategoryAmounts[index],
              index,
              animation,
            );
          },
        ),

        // Add button with dashed border effect
        GestureDetector(
          onTap: _addSubcategoryAmount,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 4.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.w),
              border: Border.all(
                color: (_isDarkMode ? AppTheme.textDark : Colors.black87)
                    .withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(1.5.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (_isDarkMode ? AppTheme.textDark : Colors.black87)
                        .withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.add,
                    color: _isDarkMode ? AppTheme.textDark : Colors.black87,
                    size: 18.sp,
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  'Ajouter une sous-catégorie',
                  style: TextStyle(
                    color: _isDarkMode ? AppTheme.textDark : Colors.black87,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _addSubcategoryAmount() {
    final newItem = {
      'subcategoryController': TextEditingController(),
      'amountController': TextEditingController(),
    };

    final insertIndex = _subcategoryAmounts.length;

    setState(() {
      _subcategoryAmounts.add(newItem);
    });

    _listKey.currentState?.insertItem(insertIndex);
  }

  void _removeSubcategoryAmount(int index) {
    if (index >= _subcategoryAmounts.length) return;

    final removedItem = _subcategoryAmounts[index];

    setState(() {
      _subcategoryAmounts.removeAt(index);
    });

    _listKey.currentState?.removeItem(
      index,
      (context, animation) =>
          _buildRemovedSubcategoryItem(removedItem, animation),
      duration: const Duration(milliseconds: 300),
    );

    // Dispose controllers after animation
    Future.delayed(const Duration(milliseconds: 300), () {
      removedItem['subcategoryController']?.dispose();
      removedItem['amountController']?.dispose();
    });
  }

  void _clearAllSubcategoryAmounts() {
    if (_subcategoryAmounts.isEmpty) return;

    // Remove items in reverse order to maintain correct indices
    for (int i = _subcategoryAmounts.length - 1; i >= 0; i--) {
      final removedItem = _subcategoryAmounts[i];

      _listKey.currentState?.removeItem(
        i,
        (context, animation) =>
            _buildRemovedSubcategoryItem(removedItem, animation),
        duration: Duration(milliseconds: 200 + (i * 50)), // Staggered animation
      );

      // Dispose controllers after animation
      Future.delayed(Duration(milliseconds: 250 + (i * 50)), () {
        removedItem['subcategoryController']?.dispose();
        removedItem['amountController']?.dispose();
      });
    }

    setState(() {
      _subcategoryAmounts.clear();
    });
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: Text(
          'Nouvel dépense',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 18.sp,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: IconButton(
              onPressed: () => context.pop(),
              icon: Icon(
                Icons.close,
                size: 21.sp,
              )),
        ),
      ],
    );
  }

  Padding _buildAddButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 5.w),
      child: CustomButton(
        text: 'Confirmer',
        backgroundColor: Colors.white,
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

          await _module.addExpense(
            _designationController.text.trim(),
            _descriptionController.text.trim(),
            _selectedCategory!.name ?? '',
            _montantController.text.trim(),
            formKey: _formKey,
            ref: ref,
            context: context,
          );

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
            color: _isDarkMode
                ? AppTheme.secondaryDark.withOpacity(0.5)
                : Colors.grey[50],
            borderRadius: BorderRadius.circular(2.w),
            border: Border.all(
              color: _isDarkMode ? AppTheme.borderColorDark : Colors.grey[300]!,
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: item['subcategoryController'],
                  decoration: InputDecoration(
                    hintText: 'Sous-catégorie',
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
                    color: _isDarkMode ? AppTheme.textDark : Colors.black,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              Container(
                height: 4.h,
                width: 1,
                color:
                    (_isDarkMode ? AppTheme.borderColorDark : Colors.grey[400]!)
                        .withOpacity(0.5),
                margin: EdgeInsets.symmetric(horizontal: 2.w),
              ),
              Expanded(
                child: TextFormField(
                  controller: item['amountController'],
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
                    color: _isDarkMode ? AppTheme.textDark : Colors.black,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              GestureDetector(
                onTap: () => _removeSubcategoryAmount(index),
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(1.w),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
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
              color: _isDarkMode
                  ? AppTheme.secondaryDark.withOpacity(0.5)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(2.w),
              border: Border.all(
                color:
                    _isDarkMode ? AppTheme.borderColorDark : Colors.grey[300]!,
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: item['subcategoryController'],
                    decoration: InputDecoration(
                      hintText: 'Sous-catégorie',
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
                      color: _isDarkMode ? AppTheme.textDark : Colors.black,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                Container(
                  height: 4.h,
                  width: 1,
                  color: (_isDarkMode
                          ? AppTheme.borderColorDark
                          : Colors.grey[400]!)
                      .withOpacity(0.5),
                  margin: EdgeInsets.symmetric(horizontal: 2.w),
                ),
                Expanded(
                  child: TextFormField(
                    controller: item['amountController'],
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
                      color: _isDarkMode ? AppTheme.textDark : Colors.black,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(1.w),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
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
}
