import 'package:budgets/core/theme.dart';
import 'package:budgets/features/user/domain/provider/user_providers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shimmer/shimmer.dart';

class CustomGreetingAppBar extends ConsumerWidget
    implements PreferredSizeWidget {
  final VoidCallback? onNotificationPressed;

  const CustomGreetingAppBar({
    super.key,
    this.onNotificationPressed,
  });

  Widget _avatarSkeleton(double size) {
    return Shimmer.fromColors(
      baseColor: AppTheme.secondaryDark,
      highlightColor: AppTheme.borderColorDark,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.borderColorDark,
        ),
      ),
    );
  }
  Widget _textSkeleton(double width, double height) {
    return Shimmer.fromColors(
      baseColor: AppTheme.secondaryDark,
      highlightColor: AppTheme.borderColorDark,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget _avatar(String? url, double size) {
    if (url == null || url.isEmpty) {
      return ClipOval(
        child: Image.asset(
          'assets/profil.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, _) => _avatarSkeleton(size),
        errorWidget: (context, _, __) => Image.asset(
          'assets/profil.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double avatarSize = 24.sp;

    final userAsync = ref.watch(userModelProvider);

    return PreferredSize(
      preferredSize: preferredSize,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                userAsync.when(
                  data: (user) {
                    return _avatar(user?.profilePhoto, avatarSize);
                  },
                  loading: () => _avatarSkeleton(avatarSize),
                  error: (_, __) => _avatarSkeleton(avatarSize),
                ),
                userAsync.when(
                  data: (user) {
                    final username = user?.name ?? 'Utilisateur';
                    return Padding(
                      padding: EdgeInsets.only(left: 4.w),
                      child: Text(
                        'Salut, $username',
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                  loading: () => Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child: _textSkeleton(40.w, 2.4.h),
                  ),
                  error: (_, __) => Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child: _textSkeleton(40.w, 2.4.h),
                  ),
                ),
              ],
            ),
            IconButton(
                icon: Icon(
                  Icons.notifications,
                  size: 21.sp,
                  color: Colors.white,
                ),
                onPressed: onNotificationPressed),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(10.h);
}
