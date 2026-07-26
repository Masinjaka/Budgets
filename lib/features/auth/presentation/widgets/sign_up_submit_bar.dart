import 'package:budgets/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class SignUpSubmitBar extends StatelessWidget {
  const SignUpSubmitBar({
    required this.isLoading,
    required this.isEnabled,
    required this.onPressed,
    super.key,
  });

  final bool isLoading;
  final bool isEnabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: CustomButton(
        text: 'Suivant',
        isLoading: isLoading,
        onPressed: isEnabled ? onPressed : null,
      ),
    );
  }
}
