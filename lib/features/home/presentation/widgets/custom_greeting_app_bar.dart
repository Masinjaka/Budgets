import 'package:budgets/features/user/domain/provider/user_providers.dart';
import 'package:budgets/widgets/skeleton/profile_picture_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomGreetingAppBar extends ConsumerWidget
    implements PreferredSizeWidget {
  final VoidCallback? onNotificationPressed;

  const CustomGreetingAppBar({
    super.key,
    this.onNotificationPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double avatarSize = 24;
    final userAsync = ref.watch(userModelProvider);

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      elevation: 4,
      toolbarHeight: 56,
      titleSpacing: 32,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                userAsync.when(
                  data: (user) {
                    if (user == null) {
                      return avatarSkeleton(context, avatarSize);
                    }
                    return avatar(context, user.profilePhoto, avatarSize);
                  },
                  loading: () => avatarSkeleton(context, avatarSize),
                  error: (_, __) => avatarSkeleton(context, avatarSize),
                ),
                userAsync.when(
                  data: (user) {
                    if (user == null) {
                      return Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            textSkeleton(context, 80, 12.8),
                            SizedBox(height: 4),
                            textSkeleton(context, 120, 16),
                          ],
                        ),
                      );
                    }
                    final username = user.name;
                    if (username == null || username.trim().isEmpty) {
                      return _userTextSkeleton(context);
                    }
                    return Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Bienvenue',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          Text(
                            username,
                            style: TextStyle(
                              fontSize: 16,
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
                    padding: EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        textSkeleton(context, 80, 12.8),
                        SizedBox(height: 4),
                        textSkeleton(context, 120, 16),
                      ],
                    ),
                  ),
                  error: (_, __) => _userTextSkeleton(context),
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
                        size: 18,
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
  Size get preferredSize => Size.fromHeight(56);

  Widget _userTextSkeleton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          textSkeleton(context, 80, 12.8),
          SizedBox(height: 4),
          textSkeleton(context, 120, 16),
        ],
      ),
    );
  }
}
