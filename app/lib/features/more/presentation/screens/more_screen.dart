import 'package:hacktracker/core/theme/field_preferences.dart';
import 'package:hacktracker/features/premium/presentation/plan_preview.dart';
import 'package:flutter/material.dart';
import 'package:hacktracker/features/backup/presentation/backup_controls.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/core/config/env.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:hacktracker/core/theme/theme_mode_picker.dart';
import 'package:hacktracker/core/widgets/app_widgets.dart';
import 'package:hacktracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authUserProvider).valueOrNull;
    final signedIn = user != null;
    final field = ref.watch(fieldPreferencesProvider);
    return AppScaffold(
      title: 'More',
      body: ListView(
        padding: EdgeInsets.all(context.themeSpacing.md),
        children: [
          Text('Appearance', style: context.text.titleMedium),
          SizedBox(height: context.themeSpacing.sm),
          Text(
            'Light, dark, or follow the device.',
            style: context.text.bodySmall,
          ),
          SizedBox(height: context.themeSpacing.sm),
          const ThemeModePicker(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Outdoor contrast'),
            subtitle: const Text(
              'Stronger labels and basepaths in Field Mode.',
            ),
            value: field.outdoor,
            onChanged: ref.read(fieldPreferencesProvider.notifier).setOutdoor,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Reduce motion'),
            subtitle: const Text('Keep the diamond still between plays.'),
            value: field.reduceMotion,
            onChanged: ref
                .read(fieldPreferencesProvider.notifier)
                .setReduceMotion,
          ),
          SizedBox(height: context.themeSpacing.lg),
          BackupControls(signedIn: signedIn),
          SizedBox(height: context.themeSpacing.lg),
          const PlanPreview(),
          SizedBox(height: context.themeSpacing.lg),
          Text('Account', style: context.text.titleMedium),
          SizedBox(height: context.themeSpacing.sm),
          Text(
            'Scoring stays on this phone. Sign in only if you want sync, invites, or premium.',
            style: context.text.bodySmall,
          ),
          SizedBox(height: context.themeSpacing.sm),
          if (signedIn)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.email ?? 'Signed in',
                    style: context.text.titleSmall,
                  ),
                  SizedBox(height: context.themeSpacing.sm),
                  AppButton(
                    label: 'Sign out',
                    onPressed: () => Supabase.instance.client.auth.signOut(),
                  ),
                ],
              ),
            )
          else
            AppCard(
              onTap: Env.hasSupabase ? () => context.push('/sign-in') : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Not signed in', style: context.text.titleSmall),
                  SizedBox(height: context.themeSpacing.xs),
                  Text(
                    Env.hasSupabase
                        ? 'Sign in to sync and invite.'
                        : 'Cloud sync is not configured on this build.',
                    style: context.text.bodySmall,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
