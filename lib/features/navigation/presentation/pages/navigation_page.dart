import 'package:budgets/widgets/custom_navbar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:go_router/go_router.dart';

class NavigatorPage extends ConsumerStatefulWidget {
  const NavigatorPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NavigatorPageState();
}

class _NavigatorPageState extends ConsumerState<NavigatorPage> {
  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      // Use GoRouter's StatefulNavigationShell as the body to preserve state across tabs
      body: widget.navigationShell,
      bottomNavigationBar: Container(
        height: 10.h,
        decoration: const BoxDecoration(
            border:
                Border(top: BorderSide(color: Color.fromARGB(54, 48, 50, 55)))),
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomNavItem(
              icon: Icons.wallet,
              title: 'Accueil',
              onTap: () {
                widget.navigationShell.goBranch(0);
              },
              isActive: widget.navigationShell.currentIndex == 0,
            ),
            CustomNavItem(
              icon: Icons.list_outlined,
              title: 'Transactions',
              onTap: () {
                widget.navigationShell.goBranch(1);
              },
              isActive: widget.navigationShell.currentIndex == 1,
            ),
            CustomNavItem(
              icon: Icons.query_stats,
              title: 'Rapports',
              onTap: () {
                widget.navigationShell.goBranch(2);
              },
              isActive: widget.navigationShell.currentIndex == 2,
            ),
            CustomNavItem(
              icon: Icons.savings,
              title: 'Planifier',
              onTap: () {
                widget.navigationShell.goBranch(3);
              },
              isActive: widget.navigationShell.currentIndex == 3,
            ),
            CustomNavItem(
              icon: Icons.settings_outlined,
              title: 'Paramètres',
              onTap: () {
                widget.navigationShell.goBranch(4);
              },
              isActive: widget.navigationShell.currentIndex == 4,
            ),
          ],
        ),
      ),
    );
  }
}
