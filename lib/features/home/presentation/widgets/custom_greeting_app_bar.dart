import 'package:budgets/features/user/domain/provider/user_providers.dart';
import 'package:budgets/widgets/skeleton/profile_picture_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class CustomGreetingAppBar extends ConsumerWidget
    implements PreferredSizeWidget {
  final VoidCallback? onNotificationPressed;

  const CustomGreetingAppBar({
    super.key,
    this.onNotificationPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double avatarSize = 24.sp;
    final userAsync = ref.watch(userModelProvider);
    final fallbackTextStyle = TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).textTheme.bodyLarge?.color,
    );

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 4,
      toolbarHeight: 7.h,
      titleSpacing: 8.w,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                userAsync.when(
                  data: (user) {
                    return avatar(context, user?.profilePhoto, avatarSize);
                  },
                  loading: () => avatarSkeleton(context, avatarSize),
                  error: (_, __) => avatar(context, null, avatarSize),
                ),
                userAsync.when(
                  data: (user) {
                    final username = user?.name ?? 'Utilisateur';
                    return Padding(
                      padding: EdgeInsets.only(left: 4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Bienvenue',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          Text(
                            username,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        textSkeleton(context, 20.w, 1.6.h),
                        SizedBox(height: 0.5.h),
                        textSkeleton(context, 30.w, 2.h),
                      ],
                    ),
                  ),
                  error: (_, __) => Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child: Text(
                      'Utilisateur',
                      style: fallbackTextStyle,
                    ),
                  ),
                ),
              ],
            ),
            Wrap(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                      icon: Icon(
                        Icons.notifications_none_rounded,
                        size: 18.sp,
                        color: Theme.of(context).colorScheme.inverseSurface,
                      ),
                      onPressed: onNotificationPressed),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(7.h);
}
