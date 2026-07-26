import 'package:budgets/core/ui/app_typography.dart';
import 'package:budgets/features/user/domain/provider/user_providers.dart';
import 'package:budgets/widgets/skeleton/profile_picture_skeleton.dart';
import 'package:budgets/l10n/app_localizations_context.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsProfileHeader extends ConsumerWidget {
  const SettingsProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userModelProvider);
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: user.when(
            data: (value) => value == null ||
                    value.profilePhoto == null ||
                    value.profilePhoto!.isEmpty
                ? _placeholder(context)
                : avatar(context, value.profilePhoto, 80),
            loading: () => avatarSkeleton(context, 80),
            error: (_, __) => _placeholder(context),
          ),
        ),
        const SizedBox(height: 14),
        user.when(
          data: (value) => Text(
            value?.name?.trim().isNotEmpty == true
                ? value!.name!.trim()
                : context.l10n.user,
            style: const TextStyle(
              fontSize: AppTypography.body,
              fontWeight: FontWeight.w700,
            ),
          ),
          loading: () => textSkeleton(context, 72, 14),
          error: (_, __) => Text(context.l10n.user),
        ),
      ],
    );
  }

  Widget _placeholder(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person_outline_rounded, size: 38),
      );
}
