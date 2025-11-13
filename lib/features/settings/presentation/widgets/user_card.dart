import 'package:budgets/core/theme.dart';
import 'package:budgets/features/user/domain/provider/user_providers.dart';
import 'package:budgets/main.dart';
import 'package:budgets/widgets/skeleton/profile_picture_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class UserCard extends ConsumerWidget {
  const UserCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userModelProvider);

    final userEmail = supabase.auth.currentSession?.user.email ?? 'No Email';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark,
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: Wrap(
        spacing: 4.w,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          userAsync.when(
            data: (user) {
              return avatar(user?.profilePhoto, 32.sp);
            },
            loading: () => avatarSkeleton(32.sp),
            error: (_, __) => avatarSkeleton(32.sp),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              userAsync.when(
                data: (user) => Text(
                  user!.name ?? 'Utilisateur',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                loading: () => SizedBox(
                  width: 20.w,
                  height: 4.h,
                  child: const CircularProgressIndicator(
                    color: Colors.grey,
                  ),
                ),
                error: (_, __) => Text(
                  'Erreur de chargement',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.red,
                  ),
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                userEmail,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
