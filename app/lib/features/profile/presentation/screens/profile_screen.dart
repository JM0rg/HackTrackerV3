import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/supabase_providers.dart';
import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../auth/data/auth_repository.dart';
import '../../data/profile_repository.dart';

/// Account screen: shows identity (display name + email) and the sign-out action.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Sign out?',
      message:
          'Your data stays on this device and re-syncs when you sign '
          'back in.',
      confirmLabel: 'Sign out',
    );
    if (confirmed) await ref.read(authRepositoryProvider).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(supabaseClientProvider);
    final email = client.auth.currentUser?.email ?? '';
    final profile = ref.watch(myProfileProvider).value;
    final displayName = profile?.displayName;
    final initials = _initialsFor(displayName, email);
    final spacing = context.themeSpacing;
    final colors = context.colors;

    return AppScaffold(
      title: 'Profile',
      body: ListView(
        children: [
          SizedBox(height: spacing.md),
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colors.primary.withValues(alpha: 0.15),
                  child: Text(
                    initials,
                    style: context.text.titleM.copyWith(color: colors.primary),
                  ),
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName ?? 'Signed in',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleM,
                      ),
                      if (email.isNotEmpty)
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.caption,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.xl),
          AppButton(
            label: 'Sign out',
            variant: AppButtonVariant.secondary,
            onPressed: () => _signOut(context, ref),
          ),
        ],
      ),
    );
  }

  String _initialsFor(String? displayName, String email) {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) {
      final parts = name.split(RegExp(r'\s+')).take(2);
      return parts.map((p) => p.characters.first.toUpperCase()).join();
    }
    if (email.isNotEmpty) return email.characters.first.toUpperCase();
    return '?';
  }
}
