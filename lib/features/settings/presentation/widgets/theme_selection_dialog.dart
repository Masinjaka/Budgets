import 'package:budgets/core/theme.dart';
import 'package:budgets/features/settings/domain/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ThemeSelectionDialog extends StatefulWidget {
  final ThemeMode currentTheme;
  final Function(ThemeOptions) onThemeChanged;

  const ThemeSelectionDialog({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  State<ThemeSelectionDialog> createState() => _ThemeSelectionDialogState();
}

class _ThemeSelectionDialogState extends State<ThemeSelectionDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    int initialIndex = 2; // System
    if (widget.currentTheme == ThemeMode.light) initialIndex = 0;
    if (widget.currentTheme == ThemeMode.dark) initialIndex = 1;

    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: initialIndex,
    );

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        switch (_tabController.index) {
          case 0:
            widget.onThemeChanged(ThemeOptions.light);
            break;
          case 1:
            widget.onThemeChanged(ThemeOptions.dark);
            break;
          case 2:
            widget.onThemeChanged(ThemeOptions.system);
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final surfaceDim = Theme.of(context).colorScheme.surface;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Apparence',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 3.h),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: surfaceDim,
                borderRadius: BorderRadius.circular(50),
              ),
              padding: EdgeInsets.all(1.w),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(50),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: AppTheme.interactiveTextColor,
                unselectedLabelColor: textColor,
                labelStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.normal,
                ),
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    return states.contains(WidgetState.focused)
                        ? null
                        : Colors.transparent;
                  },
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wb_sunny_rounded, size: 16),
                        SizedBox(width: 1.w),
                        const Text('Jour'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.nightlight_round, size: 16),
                        SizedBox(width: 1.w),
                        const Text('Nuit'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.brightness_auto_rounded, size: 16),
                        SizedBox(width: 1.w),
                        const Text('Système'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
