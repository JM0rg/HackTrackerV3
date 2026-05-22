import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Opens the on-device SQLite database. `drift_flutter` handles the platform
/// path and bundled native library.
QueryExecutor openConnection() {
  return driftDatabase(name: 'hacktracker');
}
