import 'package:flutter/material.dart';

class AddSubcategoryCard extends StatelessWidget {
  final VoidCallback onAdd;

  const AddSubcategoryCard({
    super.key,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        margin: EdgeInsets.only(right: 12),
        height: 160,
        width: 100,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Icon(
            Icons.add,
            size: 24,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }
}
