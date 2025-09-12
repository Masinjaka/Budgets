import 'package:budgets/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

// A reusable search bar widget
class ReusableSearchBar extends StatefulWidget {
  final bool isSearchFocused;
  final VoidCallback? onSearchFocused;
  final VoidCallback? onSearchUnfocused;
  final VoidCallback? onClearSearch;
  final TextEditingController? controller;
  final String hintText;

  const ReusableSearchBar({
    super.key,
    this.isSearchFocused = false,
    this.onSearchFocused,
    this.onSearchUnfocused,
    this.onClearSearch,
    this.controller,
    this.hintText = '',
  });

  @override
  State<ReusableSearchBar> createState() => _ReusableSearchBarState();
}

class _ReusableSearchBarState extends State<ReusableSearchBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onTextChanged);
    _hasText = widget.controller?.text.isNotEmpty ?? false;
  }

  @override
  void didUpdateWidget(ReusableSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onTextChanged);
      widget.controller?.addListener(_onTextChanged);
      _hasText = widget.controller?.text.isNotEmpty ?? false;
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller?.text.isNotEmpty ?? false;
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 5.h,
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: AppTheme.borderColorDark),
      ),
      child: TextField(
        controller: widget.controller,
        cursorColor: Colors.white,
        style: const TextStyle(color: Colors.white),
        onTap: widget.onSearchFocused,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Color(0xFF8E8E93)),
          prefixIcon: widget.isSearchFocused
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF8E8E93)),
                  onPressed: widget.onSearchUnfocused,
                )
              : const Icon(Icons.search, color: Color(0xFF8E8E93)),
          suffixIcon: widget.isSearchFocused && _hasText
              ? IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF8E8E93)),
                  onPressed: widget.onClearSearch,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.5.h),
        ),
      ),
    );
  }
}