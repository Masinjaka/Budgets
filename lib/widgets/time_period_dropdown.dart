import 'package:budgets/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class TimePeriodDropdown extends ConsumerStatefulWidget {
  const TimePeriodDropdown({
    super.key,
    this.onChanged,
    this.selectedValue,
    this.defaultText = 'Sélectionner',
  });

  final void Function(String?)? onChanged;
  final String? selectedValue;
  final String defaultText;

  @override
  ConsumerState<TimePeriodDropdown> createState() => _TimePeriodDropdownState();
}

class _TimePeriodDropdownState extends ConsumerState<TimePeriodDropdown>
    with SingleTickerProviderStateMixin {
  String? _selectedItem;
  bool _isDropdownOpen = false;
  final GlobalKey _dropdownKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  late AnimationController _animationController;
  late Animation<double> _dropdownAnimation;

  final List<String> _timePeriods = [
    'Hébdomadaire',
    '1 mois',
    '3 mois',
    '1 an',
  ];

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selectedValue;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _dropdownAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCirc,
    );
  }

  @override
  void didUpdateWidget(TimePeriodDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue) {
      _selectedItem = widget.selectedValue;
    }
  }

  @override
  void dispose() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isDropdownOpen = false;
    }
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _removeOverlay();
    } else {
      _createOverlay();
    }
  }

  void _createOverlay() {
    final RenderBox renderBox =
        _dropdownKey.currentContext!.findRenderObject() as RenderBox;
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
      if (mounted) {
        await _animationController.reverse();
      }
      _overlayEntry?.remove();
      _overlayEntry = null;
    }

    if (mounted) {
      setState(() {
        _isDropdownOpen = false;
      });
    }
  }

  OverlayEntry _createOverlayEntry(Offset offset, Size size) {
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
                final scaleY = _dropdownAnimation.value;
                final slideOffset = (1 - _dropdownAnimation.value) * -20;

                return Transform.translate(
                  offset: Offset(0, slideOffset),
                  child: Transform.scale(
                    scaleY: scaleY,
                    alignment: Alignment.topCenter,
                    child: Opacity(
                      opacity: _dropdownAnimation.value,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          constraints: BoxConstraints(
                            minWidth: 40.w, // Make dropdown wider
                            maxHeight: 40.h, // Limit height to 40% of screen
                          ),
                          decoration: BoxDecoration(
                            color:
                                AppTheme.secondaryDark, // Always use dark color
                            borderRadius: BorderRadius.circular(2.w),
                            border: Border.all(
                              color: AppTheme.borderColorDark,
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                    0.1 * _dropdownAnimation.value),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2.w),
                            child: _buildDropdownItems(),
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

  Widget _buildDropdownItems() {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: _timePeriods.length,
      itemBuilder: (context, index) {
        final period = _timePeriods[index];
        final isSelected = _selectedItem == period;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedItem = period;
            });
            widget.onChanged?.call(period);
            _removeOverlay();
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 3.w,
              vertical: 2.h,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    period,
                    style: TextStyle(
                      color: Colors.white, // Always white text
                      fontSize: 15.sp,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check,
                    color: Colors.white, // Always white icon
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
    return GestureDetector(
      key: _dropdownKey,
      onTap: _toggleDropdown,
      child: SizedBox(
        width: 32.w, // Fixed width to match "Hébdomadaire" text
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                _selectedItem ?? widget.defaultText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 1.w),
            Icon(
              _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: Colors.white,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
