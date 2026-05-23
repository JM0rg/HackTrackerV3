import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/di/database_providers.dart';
import 'core/di/sync_providers.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';

/// Root widget. Wires the router and light/dark themes, kicks a sync the
/// moment auth says we're signed in (so the onboarding gate has data to act
/// on), and wipes the local DB on sign-out so a fresh sign-in on the same
/// device starts clean.
class HackTrackerApp extends ConsumerWidget {
  const HackTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authChangesProvider, (previous, next) {
      next.whenData((event) {
        final type = event.event;
        if (type == AuthChangeEvent.signedIn ||
            type == AuthChangeEvent.tokenRefreshed) {
          unawaited(ref.read(syncEngineProvider).requestSync());
        } else if (type == AuthChangeEvent.signedOut) {
          unawaited(ref.read(appDatabaseProvider).wipeUserData());
        }
      });
    });

    return MaterialApp.router(
      title: 'HackTracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
