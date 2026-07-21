import 'package:budgets/features/user/data/datasources/supabase_user_datasource.dart';
import 'package:budgets/features/user/domain/models/user_model.dart';
import 'package:budgets/widgets/skeleton/profile_picture_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DrawerProfileButton extends StatefulWidget {
  const DrawerProfileButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  State<DrawerProfileButton> createState() => _DrawerProfileButtonState();
}

class _DrawerProfileButtonState extends State<DrawerProfileButton> {
  Stream<UserModel?>? _profile;

  @override
  void initState() {
    super.initState();
    try {
      _profile = SupabaseUserDataSource(
        Supabase.instance.client,
      ).watchCurrentUserRow();
    } catch (_) {
      _profile = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Settings',
      child: InkWell(
        key: const Key('drawer-profile-button'),
        onTap: widget.onPressed,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: StreamBuilder<UserModel?>(
            stream: _profile,
            builder: (context, snapshot) {
              if (_profile != null &&
                  snapshot.connectionState == ConnectionState.waiting) {
                return avatarSkeleton(context, 38);
              }
              return avatar(context, snapshot.data?.profilePhoto, 38);
            },
          ),
        ),
      ),
    );
  }
}
