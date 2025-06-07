import 'package:budgets/pages/expenses/page/expense_page.dart';
import 'package:budgets/pages/profile/page/profile_page.dart';
import 'package:budgets/pages/subscription/page/subscription_page.dart';
import 'package:budgets/widgets/custom_navbar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final pages = const [
    ExpensePage(),
    SubscriptionsPage(),
    ProfilePage(),
  ];

  int currrentIndex = 0;

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      body: IndexedStack(
        index: currrentIndex,
        children: pages,
      ),
      bottomNavigationBar: SizedBox(
        height: 10.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomNavItem(
              icon: Icons.wallet,
              title: 'Dépenses',
              onTap: () => setState(() => currrentIndex = 0),
              isActive: currrentIndex==0,
            ),
            CustomNavItem(
              icon: Icons.money,
              title: 'Abonnements',
              onTap: () => setState(() => currrentIndex = 1),
              isActive: currrentIndex==1,
            ),
            CustomNavItem(
              icon: Icons.person,
              title: 'Profil',
              onTap: () => setState(() => currrentIndex = 2),
              isActive: currrentIndex==2,
            ),
          ],
        ),
      ),
    );
  }
}
