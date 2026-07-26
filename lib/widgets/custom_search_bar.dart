import 'package:flutter/material.dart';

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
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(200),
      ),
      child: TextFormField(
        controller: widget.controller,
        cursorColor: Theme.of(context).textTheme.bodyLarge?.color,
        style: Theme.of(context).textTheme.bodyLarge,
        onTap: widget.onSearchFocused,
        textAlign: TextAlign.start,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Theme.of(context).hintColor),
          prefixIcon: widget.isSearchFocused
              ? IconButton(
                  icon: Icon(Icons.arrow_back,
                      color: Theme.of(context).hintColor),
                  onPressed: widget.onSearchUnfocused,
                )
              : Icon(Icons.search, color: Theme.of(context).hintColor),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
          suffixIcon: widget.isSearchFocused && _hasText
              ? IconButton(
                  icon: Icon(Icons.close, color: Theme.of(context).hintColor),
                  onPressed: widget.onClearSearch,
                )
              : null,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12.8,
          ),
        ),
      ),
    );
  }
}
