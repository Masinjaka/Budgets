import 'package:budgets/features/home/presentation/pages/accueil_page.dart';
import 'package:budgets/pages/home/pages/modules/modules.dart';
import 'package:budgets/pages/profile/page/profile_page.dart';
import 'package:budgets/pages/categories/page/category_page.dart';
import 'package:budgets/widgets/custom_navbar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class NavigatorPage extends ConsumerStatefulWidget {
  const NavigatorPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NavigatorPageState();
}

class _NavigatorPageState extends ConsumerState<NavigatorPage> {
  final HomePageModule _module = HomePageModule();

  final PageController _controller = PageController();

  final pages = const [
    // ExpensePage(),
    // Updated import path in router separately
    // Placeholder, will be replaced by new HomePage
    HomePage(),
    CategoryPage(),
    // StatsPage(),
    ProfilePage(),
  ];

  int currrentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemCount: pages.length,
        itemBuilder: (context, index) => pages[index],
      ),
      bottomNavigationBar: Container(
        height: 10.h,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color.fromARGB(54, 48, 50, 55)
            )
          )
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomNavItem(
              icon: Icons.wallet,
              title: 'Accueil',
              onTap: () {
                _module.movePageTo(_controller, 0);
                setState(() => currrentIndex = 0);
              },
              isActive: currrentIndex == 0,
            ),
            CustomNavItem(
              icon: Icons.category,
              title: 'Categories',
              onTap: () {
                _module.movePageTo(_controller, 1);
                setState(() => currrentIndex = 1);
              },
              isActive: currrentIndex == 1,
            ),
            // CustomNavItem(
            //   icon: Icons.query_stats,
            //   title: 'Vue d\'ensemble',
            //   onTap: () => setState(() => currrentIndex = 2),
            //   isActive: currrentIndex==2,
            // ),
            CustomNavItem(
              icon: Icons.person,
              title: 'Profil',
              onTap: () {
                _module.movePageTo(_controller, 2);
                setState(() => currrentIndex = 2);
              },
              isActive: currrentIndex == 2,
            ),
          ],
        ),
      ),
    );
  }
}
