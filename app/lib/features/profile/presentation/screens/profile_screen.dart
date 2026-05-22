import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/supabase_providers.dart';
import '../../../../core/theme/theme_context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_scaffold.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../auth/data/auth_repository.dart';

/// Account screen: shows the signed-in identity and the sign-out action.
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
    final email = client.auth.currentUser?.email ?? 'Signed in';
    final spacing = context.themeSpacing;

    return AppScaffold(
      title: 'Profile',
      body: ListView(
        children: [
          SizedBox(height: spacing.md),
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: context.colors.primary.withValues(
                    alpha: 0.15,
                  ),
                  child: Icon(Icons.person, color: context.colors.primary),
                ),
                SizedBox(width: spacing.md),
                Expanded(
                  child: Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.body,
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
}
