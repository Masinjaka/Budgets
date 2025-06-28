import 'package:budgets/core/theme.dart';
import 'package:budgets/provider/auth_provider.dart';
import 'package:budgets/widgets/custom_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomAppBar extends ConsumerStatefulWidget {
  const CustomAppBar({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends ConsumerState<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    final asyncUser = ref.watch(authProvider);

    return ListTile(
      leading: Container(
        width: 4.5.h,
        height: 4.5.h,
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(5.h),
          border: Border.all(
            color: Colors.black,
          ),
        ),
      ),
      trailing: InkWell(
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        onTap: () {},
        child: Badge(
          label: const Text(
            '10',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 185, 180),
          padding: EdgeInsets.all(0.5.w),
          child: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.h),
              border: Border.all(color: Colors.black),
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: Colors.black,
            ),
          ),
        ),
      ),
      title: switch (asyncUser) {
        AsyncData(:final value) => Text(
            value.name!,
            style: TextStyle(
              fontSize: 15.5.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        AsyncError() => const Text('Oops, something unexpected happened'),
        _ => const CustomSkeleton(),
      },
      subtitle: const Text('Bienvenue'),
    );
  }
}
