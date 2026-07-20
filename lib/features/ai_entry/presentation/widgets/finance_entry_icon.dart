import 'package:flutter/material.dart';

class FinanceEntryIcon extends StatelessWidget {
  const FinanceEntryIcon({required this.iconKey, super.key});

  final String iconKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: const BoxDecoration(
        color: Color(0xFFEEEEEE),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(_iconFor(iconKey), size: 21, color: Colors.black),
    );
  }

  IconData _iconFor(String key) => switch (key) {
        'food' => Icons.fastfood_outlined,
        'shopping' => Icons.shopping_cart_outlined,
        'transport' => Icons.directions_car_outlined,
        'housing' => Icons.home_outlined,
        'health' => Icons.medical_services_outlined,
        'entertainment' => Icons.movie_outlined,
        'education' => Icons.school_outlined,
        'utilities' => Icons.lightbulb_outline,
        'salary' => Icons.work_outline,
        'freelance' => Icons.laptop_mac_outlined,
        'income' => Icons.payments_outlined,
        'transfer' => Icons.swap_vert_rounded,
        _ => Icons.receipt_long_outlined,
      };
}
