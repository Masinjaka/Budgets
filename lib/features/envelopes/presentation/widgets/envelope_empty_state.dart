import 'package:flutter/material.dart';

class EnvelopeEmptyState extends StatelessWidget {
  const EnvelopeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 42),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(Icons.mail_outline_rounded, size: 34),
          SizedBox(height: 12),
          Text(
            'No envelopes yet',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 5),
          Text(
            'Set a monthly amount for an expense category. Chat expenses '
            'will update it automatically.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF747474), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
