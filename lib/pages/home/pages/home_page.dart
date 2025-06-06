import 'package:budgets/provider/auth_provider.dart';
import 'package:budgets/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Home page'),
            CustomButton(
              text: 'Logout',
              onPressed: () async {
                ref.read(authProvider.notifier).signOut().then(
                  (value) {
                    if (mounted) {
                      context.go('/login');
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
