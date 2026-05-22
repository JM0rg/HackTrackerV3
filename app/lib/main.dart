import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/di/database_providers.dart';
import 'core/di/sync_providers.dart';
import 'features/games/services/games_syncer.dart';
import 'features/groups/services/game_groups_syncer.dart';
import 'features/groups/services/groups_syncer.dart';
import 'features/lineups/services/lineup_slots_syncer.dart';
import 'features/lineups/services/lineups_syncer.dart';
import 'features/players/services/players_syncer.dart';
import 'features/teams/services/teams_syncer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!Env.hasSupabaseConfig) {
    runApp(const _ConfigErrorApp());
    return;
  }

  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);

  runApp(
    ProviderScope(
      overrides: [
        // Register feature syncers in FK-dependency order.
        syncersProvider.overrideWith(
          (ref) => [
            TeamsSyncer(ref.watch(appDatabaseProvider)),
            PlayersSyncer(ref.watch(appDatabaseProvider)),
            GroupsSyncer(ref.watch(appDatabaseProvider)),
            GamesSyncer(ref.watch(appDatabaseProvider)),
            GameGroupsSyncer(ref.watch(appDatabaseProvider)),
            LineupsSyncer(ref.watch(appDatabaseProvider)),
            LineupSlotsSyncer(ref.watch(appDatabaseProvider)),
          ],
        ),
      ],
      child: const HackTrackerApp(),
    ),
  );
}

/// Shown when the app is launched without Supabase credentials (missing
/// `--dart-define`s). See README for the run command.
class _ConfigErrorApp extends StatelessWidget {
  const _ConfigErrorApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Missing Supabase configuration.\n\n'
              'Run with --dart-define=SUPABASE_URL=... '
              '--dart-define=SUPABASE_ANON_KEY=...',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
