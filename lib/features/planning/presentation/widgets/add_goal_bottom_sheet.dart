import 'dart:io';

import 'package:budgets/core/currency/currency_provider.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/core/functions/pick_image_with_permissions.dart';
import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/core/utils/amount_formatter.dart';
import 'package:budgets/core/utils/animated_dialog.dart';
import 'package:budgets/features/categories/domain/models/category_model.dart';
import 'package:budgets/features/categories/domain/providers/category_provider.dart';
import 'package:budgets/features/categories/presentation/widgets/add_category_dialog.dart';
import 'package:budgets/features/planning/domain/models/goal_model.dart';
import 'package:budgets/features/planning/domain/providers/goal_provider.dart';
import 'package:budgets/widgets/animated_amount_field.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:budgets/widgets/custom_textfield.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Dialog for adding or editing a goal.
class AddGoalBottomSheet extends ConsumerStatefulWidget {
  final Goal? goal;

  const AddGoalBottomSheet({super.key, this.goal});

  static Future<bool?> show(BuildContext context, {Goal? goal}) {
    return showAnimatedDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AddGoalBottomSheet(goal: goal),
    );
  }

  @override
  ConsumerState<AddGoalBottomSheet> createState() => _AddGoalBottomSheetState();
}

class _AddGoalBottomSheetState extends ConsumerState<AddGoalBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  DateTime? _targetDate;
  String? _imagePath;
  String? _selectedCategoryId;
  bool _isLoading = false;

  bool get _isEditing => widget.goal != null;

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _nameController.text = widget.goal!.name ?? '';
      _targetDate = widget.goal!.dateAim;
      _imagePath = widget.goal!.imagePath;
      _selectedCategoryId = widget.goal!.category?.id;
    }
    if (_targetDate != null) {
      _dateController.text =
          DateFormat('dd/MM/yyyy', 'fr_FR').format(_targetDate!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.goal?.goalAmount == null) return;
      final currencyState = await ref.read(currencyControllerProvider.future);
      final rate = currencyState.rateFor(currencyState.code);
      final amountMga = parseAmountInput(widget.goal!.goalAmount!);
      final displayAmount = convertFromMga(amountMga, rate);
      _amountController.text = formatAmountValue(displayAmount);
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
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

    if (picked == null || !mounted) return;
    setState(() {
      _targetDate = picked;
      _dateController.text = DateFormat('dd/MM/yyyy', 'fr_FR').format(picked);
    });
  }

  Future<void> _pickImage() async {
    final file = await pickImageWithPermissions(
      context,
      description:
          'Nous avons besoin de l\'accès à vos photos pour ajouter une image à votre objectif.',
    );

    if (!mounted || file == null) return;
    setState(() => _imagePath = file.path);
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

  Future<void> _saveGoal() async {
    if (_nameController.text.trim().isEmpty ||
        _amountController.text.trim().isEmpty ||
        _selectedCategoryId == null) {
      showInfoToast(context, 'Veuillez remplir tous les champs requis');
      return;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      showAppToast(
        context,
        'Utilisateur non authentifié',
        type: AppToastType.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currencyState = await ref.read(currencyControllerProvider.future);
      final rate = currencyState.rateFor(currencyState.code);
      final displayAmount = parseAmountInput(_amountController.text);
      final goalAmountMga = convertToMga(displayAmount, rate).round();

      final goal = Goal(
        id: widget.goal?.id,
        userId: userId,
        name: _nameController.text.trim(),
        category: Category(id: _selectedCategoryId),
        goalAmount: goalAmountMga.toString(),
        currentAmount: widget.goal?.currentAmount ?? '0',
        dateAim: _targetDate,
        imagePath: _imagePath,
      );

      if (_isEditing) {
        await ref.read(goalsProvider.notifier).updateSomeGoal(
              goal,
              oldImagePath: widget.goal?.imagePath,
            );
      } else {
        await ref.read(goalsProvider.notifier).addSomeGoal(goal);
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on SocketException {
      if (mounted) {
        showInfoToast(
          context,
          'Erreur réseau: Vérifiez votre connexion internet',
        );
      }
    } on StorageException catch (e) {
      if (mounted) {
        showErrorToast(context, e);
      }
    } on FileSystemException {
      if (mounted) {
        showAppToast(
          context,
          "Impossible d'accéder au fichier image",
          type: AppToastType.error,
        );
      }
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
                        _isEditing ? 'Modifier l\'objectif' : 'Nouvel objectif',
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
                _buildNameField(),
                SizedBox(height: 2.h),
                _buildDatePicker(),
                SizedBox(height: 2.h),
                _buildImagePicker(),
                SizedBox(height: 3.h),
                CustomButton(
                  text: _isEditing ? 'Modifier' : 'Ajouter',
                  onPressed: _saveGoal,
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
          loading: () => SizedBox(
            height: 5.2.h,
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          error: (e, _) => Text('Erreur: $e'),
        ),
      ],
    );
  }

  Widget _buildCategoryPills(List<Category> categories) {
    final expenseCategories = categories
        .where((category) => category.transactionType?.value == 'expense')
        .toList();

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

  Widget _buildNameField() {
    return CustomTextField(
      title: Text(
        'Nom',
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      controller: _nameController,
      hint: 'Ex: Nouvelle voiture',
      validator: const <String, String>{
        'type': 'required',
        'error': 'Veuillez renseigner le nom',
      },
    );
  }

  Widget _buildDatePicker() {
    return CustomTextField(
      title: Text(
        'Date cible (optionnel)',
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      controller: _dateController,
      isReadOnly: true,
      onTap: _selectDate,
      hint: 'Sélectionner une date',
      suffixIcon: Icon(
        Icons.calendar_today,
        size: 18.sp,
        color: Theme.of(context).hintColor,
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Image',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: 1.h),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: 15.h,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(3.w),
              border: Border.all(
                color: Theme.of(context).hintColor.withAlpha(75),
                style: BorderStyle.solid,
              ),
            ),
            child: _imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(3.w),
                    child: _imagePath!.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: _imagePath!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          )
                        : Image.file(
                            File(_imagePath!),
                            fit: BoxFit.cover,
                          ),
                  )
                : Center(
                    child: Icon(
                      Icons.add,
                      size: 25.sp,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
