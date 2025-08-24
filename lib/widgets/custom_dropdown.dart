import 'package:budgets/core/theme.dart';
import 'package:budgets/model/category_model.dart';
import 'package:budgets/provider/app_theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomDropdown extends ConsumerStatefulWidget {
  const CustomDropdown({
    super.key,
    required this.title,
    this.hint,
    required this.items,
    this.onChanged,
    this.validator,
    this.selectedValue,
    this.enabled = true,
    this.showEmojis = true,
    this.showColors = false,
  });

  final Widget title;
  final String? hint;
  final List<Category> items;
  final void Function(Category?)? onChanged;
  final Map<String, String>? validator;
  final Category? selectedValue;
  final bool enabled;
  final bool showEmojis;
  final bool showColors;

  @override
  ConsumerState<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends ConsumerState<CustomDropdown>
    with SingleTickerProviderStateMixin {
  Category? _selectedItem;
  bool _isDropdownOpen = false;
  final GlobalKey _dropdownKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  late AnimationController _animationController;
  late Animation<double> _dropdownAnimation;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selectedValue;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200), // Slightly longer for better curve effect
    );
    
    // Create curved animation with fast-out-slow-in
    _dropdownAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCirc,
    );
  }

  @override
  void didUpdateWidget(CustomDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue) {
      _selectedItem = widget.selectedValue;
    }
    
    // Close dropdown if the widget becomes disabled or items change
    if ((!widget.enabled || widget.items.isEmpty) && _isDropdownOpen) {
      _removeOverlay();
    }
  }

  @override
  void dispose() {
    // Immediately remove overlay without animation to avoid setState after dispose
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isDropdownOpen = false; // Set state directly without setState
    }
    _animationController.dispose();
    super.dispose();
  }

  String? validate(String type, String? error, Category? value) {
    switch (type) {
      case 'required':
        return value == null ? (error ?? "Ce champ est requis") : null;
      default:
        return null;
    }
  }

  void _toggleDropdown() {
    if (!widget.enabled || widget.items.isEmpty) return;
    
    if (_isDropdownOpen) {
      _removeOverlay();
    } else {
      _createOverlay();
    }
  }

  void _createOverlay() {
    final RenderBox renderBox = _dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    
    _overlayEntry = _createOverlayEntry(offset, size);
    Overlay.of(context).insert(_overlayEntry!);
    
    setState(() {
      _isDropdownOpen = true;
    });
    
    _animationController.forward();
  }

  void _removeOverlay() async {
    if (_overlayEntry != null) {
      // Check if widget is still mounted before starting animation
      if (mounted) {
        await _animationController.reverse();
      }
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
    
    // Double check mounted state after async operation
    if (mounted) {
      setState(() {
        _isDropdownOpen = false;
      });
    }
  }

  OverlayEntry _createOverlayEntry(Offset offset, Size size) {
    final globalTheme = ref.watch(globalThemeProvider);
    final isDarkMode = globalTheme == Brightness.dark;
    
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Invisible barrier to detect clicks outside
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeOverlay,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // Actual dropdown
          Positioned(
            left: offset.dx,
            top: offset.dy + size.height,
            width: size.width,
            child: AnimatedBuilder(
              animation: _dropdownAnimation,
              builder: (context, child) {
                // Create a "drop down" effect by scaling from top and sliding down
                final scaleY = _dropdownAnimation.value;
                final slideOffset = (1 - _dropdownAnimation.value) * -20; // Slide down from above
                
                return Transform.translate(
                  offset: Offset(0, slideOffset),
                  child: Transform.scale(
                    scaleY: scaleY,
                    alignment: Alignment.topCenter, // Scale from the top edge
                    child: Opacity(
                      opacity: _dropdownAnimation.value,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          constraints: BoxConstraints(
                            maxHeight: 40.h, // Limit height to 40% of screen
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode ? AppTheme.secondaryDark : Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(2.w),
                              bottomRight: Radius.circular(2.w),
                            ),
                            border: Border(
                              left: BorderSide(
                                color: isDarkMode ? AppTheme.borderColorDark : Colors.black54,
                                width: 1.0,
                              ),
                              right: BorderSide(
                                color: isDarkMode ? AppTheme.borderColorDark : Colors.black54,
                                width: 1.0,
                              ),
                              bottom: BorderSide(
                                color: isDarkMode ? AppTheme.borderColorDark : Colors.black54,
                                width: 1.0,
                              ),
                              // No top border to seamlessly connect with text field
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1 * _dropdownAnimation.value),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(2.w),
                              bottomRight: Radius.circular(2.w),
                            ),
                            child: widget.items.isEmpty
                                ? _buildEmptyState(isDarkMode)
                                : _buildDropdownItems(isDarkMode),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(3.w),
      child: Text(
        'Aucune catégorie disponible',
        style: TextStyle(
          color: (isDarkMode ? AppTheme.textDark : Colors.black).withOpacity(0.5),
          fontSize: 15.sp,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildDropdownItems(bool isDarkMode) {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final category = widget.items[index];
        final isSelected = _selectedItem == category;
        
        return InkWell(
          onTap: () {
            setState(() {
              _selectedItem = category;
            });
            widget.onChanged?.call(category);
            _removeOverlay();
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 3.w,
              vertical: 2.h,
            ),
            child: Row(
              children: [
                if (widget.showEmojis && category.emoji != null)
                  Text(
                    category.emoji!,
                    style: TextStyle(fontSize: 16.sp),
                  ),
                if (widget.showEmojis && category.emoji != null)
                  SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    category.name ?? 'Catégorie sans nom',
                    style: TextStyle(
                      color: isDarkMode ? AppTheme.textDark : Colors.black,
                      fontSize: 15.sp,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 18.sp,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final globalTheme = ref.watch(globalThemeProvider);
    final isDarkMode = globalTheme == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.title,
        SizedBox(height: 1.h),
        FormField<Category>(
          validator: (Category? value) {
            return validate(
              widget.validator?['type'] ?? '',
              widget.validator?['error'] ?? '',
              _selectedItem,
            );
          },
          builder: (FormFieldState<Category> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  key: _dropdownKey,
                  onTap: _toggleDropdown,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: isDarkMode ? AppTheme.secondaryDark : Colors.white,
                      borderRadius: _isDropdownOpen 
                          ? BorderRadius.only(
                              topLeft: Radius.circular(2.w),
                              topRight: Radius.circular(2.w),
                            )
                          : BorderRadius.circular(2.w),
                      border: Border.all(
                        color: state.hasError 
                            ? Colors.red 
                            : (isDarkMode ? AppTheme.borderColorDark : Colors.black54),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (_selectedItem != null && widget.showEmojis && _selectedItem!.emoji != null)
                          Text(
                            _selectedItem!.emoji!,
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        if (_selectedItem != null && widget.showEmojis && _selectedItem!.emoji != null)
                          SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            _selectedItem?.name ?? widget.hint ?? 'Sélectionnez une option',
                            style: TextStyle(
                              color: _selectedItem != null 
                                  ? (isDarkMode ? AppTheme.textDark : Colors.black)
                                  : (isDarkMode ? AppTheme.textDark.withOpacity(0.6) : Colors.black54),
                              fontSize: 15.sp,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                          color: isDarkMode ? AppTheme.textDark : Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),
                if (state.hasError)
                  Padding(
                    padding: EdgeInsets.only(top: 1.h, left: 3.w),
                    child: Text(
                      state.errorText!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
