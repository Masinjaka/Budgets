import 'dart:io';

import 'package:budgets/core/currency/currency_provider.dart';
import 'package:budgets/core/enums/transaction_type.dart';
import 'package:budgets/core/functions/pick_image_with_permissions.dart';
import 'package:budgets/core/ui/app_toast.dart';
import 'package:budgets/core/ui/app_wheel_picker.dart';
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
  final AmountTextEditingController _amountController =
      AmountTextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final PageController _pageController = PageController();

  DateTime? _targetDate;
  String? _imagePath;
  String? _selectedCategoryId;
  int _currentStep = 0;
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
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goToNextStep() async {
    if (_nameController.text.trim().isEmpty) {
      showInfoToast(context, 'Veuillez renseigner le nom de l\'objectif');
      return;
    }

    FocusScope.of(context).unfocus();
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _selectDate() async {
    final picked = await AppWheelPicker.date(
      context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
      title: 'Select a target date',
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
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 20 + 16, vertical: 40),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
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
                          fontSize: 18,
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
                SizedBox(height: 12.8),
                _buildStepIndicator(),
                SizedBox(height: 16),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  height: _currentStep == 0 ? 192 : 376,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      if (!mounted) return;
                      setState(() => _currentStep = index);
                    },
                    children: [
                      _buildStepOne(),
                      _buildStepTwo(),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                if (_currentStep == 0)
                  CustomButton(
                    text: 'Suivant',
                    onPressed: _goToNextStep,
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          height: 49.6,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: () async {
                                FocusScope.of(context).unfocus();
                                await _pageController.previousPage(
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOutCubic,
                                );
                              },
                              splashRadius: 18,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                Icons.chevron_left,
                                size: 25,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        flex: 5,
                        child: CustomButton(
                          text: _isEditing ? 'Modifier' : 'Ajouter',
                          onPressed: _saveGoal,
                          isLoading: _isLoading,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(2, (index) {
        final isActive = _currentStep == index;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: EdgeInsets.only(right: index == 0 ? 7.2 : 0),
            height: 6.4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isActive
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).colorScheme.surfaceDim,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStepOne() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNameField(),
        SizedBox(height: 16),
        _buildDatePicker(),
      ],
    );
  }

  Widget _buildStepTwo() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedAmountField(
            controller: _amountController,
            hint: '0.00',
            fontSize: 25,
            fillColor: Theme.of(context).colorScheme.surfaceDim,
            height: 120,
            width: double.infinity,
            borderRadius: BorderRadius.circular(12),
          ),
          SizedBox(height: 16),
          _buildCategorySection(),
          SizedBox(height: 16),
          _buildImagePicker(),
          SizedBox(height: 6.4),
        ],
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
            fontSize: 15.5,
          ),
        ),
        SizedBox(height: 8),
        categoriesAsync.when(
          data: _buildCategoryPills,
          loading: () => SizedBox(
            height: 41.6,
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
      height: 41.6,
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
        margin: EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9.6),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.inverseSurface
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              category.emoji ?? '📁',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(width: 6),
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
                fontSize: 14,
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
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              size: 14,
              color: textColor,
            ),
            SizedBox(width: 4),
            Text(
              'Ajouter une catégorie',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
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
          fontSize: 15,
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
        'Échéance (optionnel)',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      controller: _dateController,
      isReadOnly: true,
      onTap: _selectDate,
      hint: 'Choisir une échéance',
      suffixIcon: Icon(
        Icons.calendar_today,
        size: 18,
        color: Theme.of(context).hintColor,
      ),
    );
  }

  Widget _buildImagePicker() {
    final imageSize = 96.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Image',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: imageSize,
            height: imageSize,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).hintColor.withAlpha(75),
                style: BorderStyle.solid,
              ),
            ),
            child: _imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
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
                      size: 18,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
