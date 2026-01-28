import 'package:budgets/core/functions/pick_image_with_permissions.dart';
import 'package:budgets/features/planning/domain/models/goal_model.dart';
import 'package:budgets/features/planning/domain/providers/goal_provider.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'dart:io';

/// Bottom sheet for adding or editing a goal
class AddGoalBottomSheet extends ConsumerStatefulWidget {
  final Goal? goal; // Pass existing goal for editing

  const AddGoalBottomSheet({super.key, this.goal});

  @override
  ConsumerState<AddGoalBottomSheet> createState() => _AddGoalBottomSheetState();
}

class _AddGoalBottomSheetState extends ConsumerState<AddGoalBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  DateTime? _targetDate;
  String? _imagePath;
  bool _isLoading = false;

  bool get _isEditing => widget.goal != null;

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _amountController.text = widget.goal!.goalAmount ?? '';
      _nameController.text = widget.goal!.name ?? '';
      _targetDate = widget.goal!.dateAim;
      _imagePath = widget.goal!.imagePath;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
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
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  Future<void> _pickImage() async {
    final file = await pickImageWithPermissions(
      context,
      description:
          'Nous avons besoin de l\'accès à vos photos pour ajouter une image à votre objectif.',
    );
    if (file != null) {
      setState(() => _imagePath = file.path);
    }
  }

  Future<void> _saveGoal() async {
    if (_nameController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez remplir tous les champs requis')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final goal = Goal(
        id: widget.goal?.id,
        name: _nameController.text,
        goalAmount: _amountController.text,
        currentAmount: widget.goal?.currentAmount ?? '0',
        dateAim: _targetDate,
        imagePath: _imagePath,
      );

      if (_isEditing) {
        await ref.read(goalsProvider.notifier).updateSomeGoal(goal);
      } else {
        await ref.read(goalsProvider.notifier).addSomeGoal(goal);
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
      initialChildSize: 0.85,
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
    return SingleChildScrollView(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHandle(),
          _buildCloseButton(),
          SizedBox(height: 2.h),
          _buildAmountInput(),
          SizedBox(height: 4.h),
          _buildNameField(),
          SizedBox(height: 3.h),
          _buildDatePicker(),
          SizedBox(height: 3.h),
          _buildImagePicker(),
        ],
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
          color: Theme.of(context).hintColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2.w),
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Align(
      alignment: Alignment.topRight,
      child: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.of(context).pop(),
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
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.w300,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          decoration: InputDecoration(
            hintText: '0.00',
            hintStyle: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.w300,
              color: Theme.of(context).hintColor.withValues(alpha: 0.5),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nom',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: 1.h),
        TextField(
          controller: _nameController,
          style: TextStyle(
            fontSize: 15.sp,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          decoration: InputDecoration(
            hintText: 'Ex: Nouvelle voiture',
            hintStyle: TextStyle(
              fontSize: 15.sp,
              color: Theme.of(context).hintColor,
            ),
            filled: false,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).hintColor.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "D'ici",
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: 1.h),
        GestureDetector(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(3.w),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _targetDate != null
                      ? DateFormat('MMMM yyyy', 'fr_FR').format(_targetDate!)
                      : 'Sélectionner une date',
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: _targetDate != null
                        ? Theme.of(context).textTheme.bodyLarge?.color
                        : Theme.of(context).hintColor,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 18.sp,
                  color: Theme.of(context).hintColor,
                ),
              ],
            ),
          ),
        ),
      ],
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
                color: Theme.of(context).hintColor.withValues(alpha: 0.3),
                style: BorderStyle.solid,
              ),
            ),
            child: _imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(3.w),
                    child: Image.file(
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

  Widget _buildBottomBar() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.fromLTRB(6.w, 1.h, 6.w, 3.h),
      child: SafeArea(
        child: CustomButton(
          text: _isEditing ? 'Modifier' : 'Ajouter',
          onPressed: _saveGoal,
          isLoading: _isLoading,
        ),
      ),
    );
  }
}
