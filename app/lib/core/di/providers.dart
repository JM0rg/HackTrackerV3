import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hacktracker/core/config/env.dart';
import 'package:hacktracker/core/services/sync/sync_engine.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final uuidProvider = Provider<Uuid>((ref) => const Uuid());

final currentTeamIdProvider = StateProvider<String?>((ref) => null);

final syncEngineProvider = Provider<SyncEngine?>((ref) {
  if (!Env.hasSupabase) return null;
  return SyncEngine(ref.watch(databaseProvider), Supabase.instance.client);
});
