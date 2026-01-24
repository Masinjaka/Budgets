import 'package:budgets/features/categories/domain/models/subcategories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:vibration/vibration.dart';

class CustomSubcategoryDropdown extends ConsumerStatefulWidget {
  const CustomSubcategoryDropdown({
    super.key,
    required this.title,
    this.hint,
    required this.items,
    this.onChanged,
    this.validator,
    this.selectedValue,
    this.enabled = true,
    this.onTap,
  });

  final Widget title;
  final String? hint;
  final List<Subcategory> items;
  final void Function(Subcategory?)? onChanged;
  final Map<String, String>? validator;
  final Subcategory? selectedValue;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  ConsumerState<CustomSubcategoryDropdown> createState() =>
      _CustomSubcategoryDropdownState();
}

class _CustomSubcategoryDropdownState
    extends ConsumerState<CustomSubcategoryDropdown>
    with SingleTickerProviderStateMixin {
  Subcategory? _selectedItem;
  bool _isDropdownOpen = false;
  late AnimationController _animationController;
  late Animation<double> _dropdownAnimation;
  late TextEditingController _searchController;
  late FocusNode _focusNode;
  List<Subcategory> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selectedValue;
    _searchController = TextEditingController();
    _focusNode = FocusNode();
    _filteredItems = widget.items;

    // Set initial text if there's a selected value
    if (_selectedItem != null) {
      _searchController.text = _selectedItem!.name ?? '';
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _dropdownAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCirc,
    );

    // Listen to search text changes
    _searchController.addListener(_onSearchChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(CustomSubcategoryDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue) {
      _selectedItem = widget.selectedValue;
      if (_selectedItem != null) {
        _searchController.text = _selectedItem!.name ?? '';
      } else {
        _searchController.clear();
      }
    }

    // Update filtered items when widget items change
    if (widget.items != oldWidget.items) {
      _filteredItems = widget.items;
      _filterItems(_searchController.text);
    }

    if ((!widget.enabled || widget.items.isEmpty) && _isDropdownOpen) {
      _closeDropdown();
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _focusNode.removeListener(_onFocusChanged);
    _searchController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterItems(_searchController.text);
    if (!_isDropdownOpen && _focusNode.hasFocus) {
      _openDropdown();
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && !_isDropdownOpen) {
      // Call onTap callback before showing dropdown
      widget.onTap?.call();
      if (_searchController.text.isNotEmpty || widget.items.isNotEmpty) {
        _openDropdown();
      }
    } else if (!_focusNode.hasFocus && _isDropdownOpen) {
      // Allow some delay for item selection
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!_focusNode.hasFocus) {
          _closeDropdown();
          _handleCustomSubcategory();
        }
      });
    }
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          return item.name?.toLowerCase().contains(query.toLowerCase()) ??
              false;
        }).toList();
      }
    });
  }

  void _handleCustomSubcategory() {
    final text = _searchController.text.trim();
    if (text.isNotEmpty) {
      // Check if the text matches any existing subcategory
      final existingSubcategory = widget.items.firstWhere(
        (item) => item.name?.toLowerCase() == text.toLowerCase(),
        orElse: () => Subcategory(name: text), // Create a custom subcategory
      );

      if (_selectedItem?.name != text) {
        setState(() {
          _selectedItem = existingSubcategory;
        });
        widget.onChanged?.call(existingSubcategory);
      }
    }
  }

  String? validate(String type, String? error, Subcategory? value) {
    switch (type) {
      case 'required':
        return value == null ? (error ?? "Ce champ est requis") : null;
      default:
        return null;
    }
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;

    if (_isDropdownOpen) {
      _closeDropdown();
    } else {
      // Call onTap callback before showing dropdown
      widget.onTap?.call();
      _focusNode.requestFocus();
      _openDropdown();
    }
  }

  void _openDropdown() {
    setState(() {
      _isDropdownOpen = true;
    });
    _animationController.forward();
  }

  void _closeDropdown() {
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isDropdownOpen = false;
        });
      }
    });
  }

  Widget _buildDropdownContent() {
    final searchText = _searchController.text.trim();
    final hasFilteredItems = _filteredItems.isNotEmpty;
    final showCustomOption = searchText.isNotEmpty &&
        !_filteredItems.any(
            (item) => item.name?.toLowerCase() == searchText.toLowerCase());

    if (!hasFilteredItems && !showCustomOption) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
        child: Text(
          searchText.isEmpty
              ? 'Aucune sous-catégorie disponible'
              : 'Aucune sous-catégorie trouvée',
          style: TextStyle(
            color:
                Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
            fontSize: 14.sp,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Show filtered subcategories
          ...(_filteredItems.map((item) {
            final isSelected = _selectedItem?.id == item.id;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedItem = item;
                  _searchController.text = item.name ?? '';
                });
                widget.onChanged?.call(item);
                _closeDropdown();
                _focusNode.unfocus();
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 4.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).highlightColor
                      : Colors.transparent,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 16.sp,
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withOpacity(0.7),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        item.name ?? '',
                        style: TextStyle(
                          color: isSelected
                              ? Theme.of(context).textTheme.bodyLarge?.color
                              : Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color
                                  ?.withOpacity(0.8),
                          fontSize: 14.sp,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList()),

          // Show custom option if search text doesn't match any existing item
          if (showCustomOption) ...[
            if (hasFilteredItems)
              Container(
                height: 1,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                color: Theme.of(context).dividerColor,
              ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                child: GestureDetector(
                  onTap: () async {
                    // Haptic feedback
                    if (await Vibration.hasVibrator()) {
                      Vibration.vibrate(duration: 10);
                    }

                    final customSubcategory = Subcategory(name: searchText);
                    setState(() {
                      _selectedItem = customSubcategory;
                    });
                    widget.onChanged?.call(customSubcategory);
                    _closeDropdown();
                    _focusNode.unfocus();
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(vertical: 1.h, horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          size: 16.sp,
                          color: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.color
                              ?.withOpacity(0.9),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Créer "$searchText"',
                          style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.color
                                ?.withOpacity(0.9),
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.title,
        SizedBox(height: 1.h),
        FormField<Subcategory>(
          validator: (value) {
            if (widget.validator != null) {
              for (String type in widget.validator!.keys) {
                final error =
                    validate(type, widget.validator![type], _selectedItem);
                if (error != null) return error;
              }
            }
            return null;
          },
          builder: (FormFieldState<Subcategory> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Input field
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceDim,
                    borderRadius: _isDropdownOpen
                        ? BorderRadius.only(
                            topLeft: Radius.circular(5.w),
                            topRight: Radius.circular(5.w),
                          )
                        : BorderRadius.circular(5.w),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _searchController,
                          focusNode: _focusNode,
                          enabled: widget.enabled,
                          decoration: InputDecoration(
                            hintText: widget.hint ??
                                'Sélectionnez ou tapez une sous-catégorie',
                            hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color
                                  ?.withOpacity(0.6),
                              fontSize: 15.sp,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 1.5.h,
                            ),
                          ),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 15.sp,
                          ),
                          onTap: () {
                            if (!_isDropdownOpen) {
                              widget.onTap?.call();
                              _openDropdown();
                            }
                          },
                        ),
                      ),
                      GestureDetector(
                        onTap: _toggleDropdown,
                        child: Padding(
                          padding: EdgeInsets.only(right: 4.w),
                          child: Icon(
                            _isDropdownOpen
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Dropdown content - directly in widget tree
                if (_isDropdownOpen)
                  SizeTransition(
                    sizeFactor: _dropdownAnimation,
                    axisAlignment: -1.0,
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: 40.h,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceDim,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(5.w),
                          bottomRight: Radius.circular(5.w),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(5.w),
                          bottomRight: Radius.circular(5.w),
                        ),
                        child: _buildDropdownContent(),
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
