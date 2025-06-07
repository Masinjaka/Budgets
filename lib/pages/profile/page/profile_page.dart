import 'package:budgets/provider/auth_provider.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {

  bool _isLoading = false;

  @override
  Widget build(BuildContext buildcontext) {
    return Scaffold(
      bottomNavigationBar: _buildSignoutButton(),
    );
  }

  Padding _buildSignoutButton() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.w),
        child: CustomButton(
          text: 'Se déconnecter',
          onPressed: () async {
            // start authenticating
            setState(() => _isLoading = true);
            await ref.read(authProvider.notifier).signOut();
            if(!mounted) return;
            context.go('/login');
            setState(() => _isLoading = false);
            // end authenticating
          },
          isLoading: _isLoading,
        ),
      );
  }
}