import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.onTap,
  });

  final String title;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            )),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(6.4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(200),
              color: Theme.of(context).cardColor,
            ),
            child: Icon(
              Icons.arrow_right_alt_sharp,
              size: 18,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        )
      ],
    );
  }
}
