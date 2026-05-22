import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/app_database.dart';

/// The app-wide [AppDatabase] singleton. Opened lazily on first read; closed
/// when the provider container is disposed.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
