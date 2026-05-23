import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/di/sync_providers.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';

/// Root widget. Wires the router and light/dark themes, and kicks a sync
/// cycle the moment auth says we're signed in so the onboarding gate has the
/// profile + teams it needs to decide where to send the user.
class HackTrackerApp extends ConsumerWidget {
  const HackTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authChangesProvider, (previous, next) {
      next.whenData((event) {
        if (event.event == AuthChangeEvent.signedIn ||
            event.event == AuthChangeEvent.tokenRefreshed) {
          ref.read(syncEngineProvider).requestSync();
        }
      });
    });

    return MaterialApp.router(
      title: 'HackTracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
