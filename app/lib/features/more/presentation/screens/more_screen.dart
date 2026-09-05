import 'package:flutter/material.dart';
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
                  Text(user.email ?? 'Signed in', style: context.text.titleSmall),
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
                        ? 'Optional. Use email to sync this team later.'
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
