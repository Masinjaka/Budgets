import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/material.dart';

class EnvelopeEmptyState extends StatelessWidget {
  const EnvelopeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 42),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.mail_outline_rounded, size: 34),
          const SizedBox(height: 12),
          Text(
            context.l10n.noEnvelopesYet,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          Text(
            context.l10n.envelopeEmptyDescription,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF747474), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
