import 'package:budgets/features/user/data/datasources/supabase_user_datasource.dart';
import 'package:budgets/features/user/domain/models/user_model.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:budgets/widgets/skeleton/profile_picture_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DrawerProfileButton extends StatefulWidget {
  const DrawerProfileButton({
    required this.onPressed,
    this.profileLoader,
    super.key,
  });

  final Future<void> Function() onPressed;
  final Future<UserModel?> Function()? profileLoader;

  @override
  State<DrawerProfileButton> createState() => _DrawerProfileButtonState();
}

class _DrawerProfileButtonState extends State<DrawerProfileButton> {
  Future<UserModel?>? _profile;

  @override
  void initState() {
    super.initState();
    _profile = _loadProfile();
  }

  Future<UserModel?>? _loadProfile() {
    final injectedLoader = widget.profileLoader;
    if (injectedLoader != null) return injectedLoader();
    try {
      final client = Supabase.instance.client;
      if (client.auth.currentUser == null) return null;
      return SupabaseUserDataSource(client).getCurrentUserRow();
    } catch (_) {
      return null;
    }
  }

  Future<void> _openSettings() async {
    await widget.onPressed();
    if (!mounted) return;
    final profile = _loadProfile();
    setState(() {
      _profile = profile;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    return Tooltip(
      message: context.l10n.settings,
      child: InkWell(
        key: const Key('drawer-profile-button'),
        onTap: _openSettings,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: profile == null
              ? avatar(context, null, 38)
              : _profileAvatar(context, profile),
        ),
      ),
    );
  }

  Widget _profileAvatar(
    BuildContext context,
    Future<UserModel?> profile,
  ) {
    return FutureBuilder<UserModel?>(
      future: profile,
      builder: (context, snapshot) =>
          snapshot.connectionState == ConnectionState.waiting
              ? avatarSkeleton(context, 38)
              : avatar(context, snapshot.data?.profilePhoto, 38),
    );
  }
}
