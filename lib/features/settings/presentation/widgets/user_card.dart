import 'package:budgets/features/user/domain/provider/user_providers.dart';
import 'package:budgets/widgets/skeleton/profile_picture_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserCard extends ConsumerWidget {
  const UserCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userModelProvider);

    final userEmail = _userEmail();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(5.w),
      ),
      child: Wrap(
        spacing: 4.w,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          userAsync.when(
            data: (user) {
              if (user == null) return avatarSkeleton(context, 32.sp);
              return avatar(context, user.profilePhoto, 32.sp);
            },
            loading: () => avatarSkeleton(context, 32.sp),
            error: (_, __) => avatarSkeleton(context, 32.sp),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              userAsync.when(
                data: (user) {
                  if (user == null) {
                    return Padding(
                      padding: EdgeInsets.only(top: 0.5.h),
                      child: textSkeleton(context, 24.w, 2.2.h),
                    );
                  }
                  final username = user.name;
                  if (username == null || username.trim().isEmpty) {
                    return Padding(
                      padding: EdgeInsets.only(top: 0.5.h),
                      child: textSkeleton(context, 24.w, 2.2.h),
                    );
                  }
                  return Text(
                    username,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  );
                },
                loading: () => Padding(
                  padding: EdgeInsets.only(top: 0.5.h),
                  child: textSkeleton(context, 24.w, 2.2.h),
                ),
                error: (_, __) => Padding(
                  padding: EdgeInsets.only(top: 0.5.h),
                  child: textSkeleton(context, 24.w, 2.2.h),
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

  String _userEmail() {
    try {
      return Supabase.instance.client.auth.currentSession?.user.email ??
          'No Email';
    } catch (_) {
      return 'No Email';
    }
  }
}
