import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:crypto/crypto.dart';
import 'package:hacktracker/database/app_database.dart';

/// Portable snapshots. The checksum detects damage, not authenticity or secrecy.
class LocalBackup {
  LocalBackup(this.db);
  final AppDatabase db;
  static const maxBytes = 32 * 1024 * 1024;

  Future<String> export() => db.transaction(() async {
    final tables = <String, Object?>{};
    for (final table in db.allTables) {
      if (table.actualTableName == 'local_sync_cursors') continue;
      tables[table.actualTableName] = [
        for (final row
            in await db
                .customSelect('SELECT * FROM "${table.actualTableName}"')
                .get())
          row.data,
      ];
    }
    final payload = jsonEncode({'schema': db.schemaVersion, 'tables': tables});
    return jsonEncode({
      'format': 'hacktracker-backup',
      'version': 1,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'sha256': sha256.convert(utf8.encode(payload)).toString(),
      'payload': payload,
    });
  });

  Map<String, List<Map<String, Object?>>> inspect(String source) {
    if (utf8.encode(source).length > maxBytes) {
      throw const FormatException('Backup exceeds 32 MB.');
    }
    final envelope = jsonDecode(source);
    if (envelope is! Map ||
        envelope['format'] != 'hacktracker-backup' ||
        envelope['version'] != 1) {
      throw const FormatException('Choose a HackTracker backup.');
    }
    final payload = envelope['payload'];
    if (payload is! String ||
        sha256.convert(utf8.encode(payload)).toString() != envelope['sha256']) {
      throw const FormatException('This backup is damaged.');
    }
    final decoded = jsonDecode(payload);
    if (decoded is! Map ||
        decoded['schema'] is! int ||
        (decoded['schema'] as int) < 7 ||
        (decoded['schema'] as int) > db.schemaVersion ||
        decoded['tables'] is! Map) {
      throw const FormatException('This backup needs a matching app version.');
    }
    final rawTables = decoded['tables'] as Map;
    if (decoded['schema'] == 7) {
      const added = {
        'games': ['scoring_draft'],
        'plate_appearances': ['resolution', 'batter_was_male'],
        'game_events': ['payload'],
      };
      for (final entry in added.entries) {
        final rows = rawTables[entry.key];
        if (rows is! List) throw const FormatException('Incomplete backup.');
        for (final row in rows) {
          if (row is! Map || entry.value.any(row.containsKey)) {
            throw const FormatException('Invalid legacy row.');
          }
          for (final column in entry.value) {
            row[column] = null;
          }
        }
      }
    }
    final expected = {
      for (final table in db.allTables)
        if (table.actualTableName != 'local_sync_cursors')
          table.actualTableName: table,
    };
    if (rawTables.length != expected.length ||
        !rawTables.keys.every(expected.containsKey)) {
      throw const FormatException('Incomplete backup.');
    }
    final result = <String, List<Map<String, Object?>>>{};
    for (final entry in expected.entries) {
      final rawRows = rawTables[entry.key];
      if (rawRows is! List) throw const FormatException('Invalid table data.');
      final columns = {for (final column in entry.value.$columns) column.$name};
      result[entry.key] = [];
      for (final raw in rawRows) {
        if (raw is! Map ||
            raw.length != columns.length ||
            !raw.keys.every(columns.contains) ||
            raw.values.any(
              (v) => v != null && v is! String && v is! num && v is! bool,
            )) {
          throw const FormatException('Invalid row data.');
        }
        result[entry.key]!.add(Map<String, Object?>.from(raw));
      }
    }
    return result;
  }

  /// The caller previews the validated snapshot and asks before replacement.
  /// Any failed insert rolls back both removal and insertion of all records.
  Future<void> restore(String source) async {
    final tables = inspect(source);
    await db.transaction(() async {
      for (final table in db.allTables.toList().reversed) {
        await db.customStatement('DELETE FROM "${table.actualTableName}"');
      }
      for (final entry in tables.entries) {
        for (final row in entry.value) {
          final columns = row.keys.map((k) => '"$k"').join(',');
          final placeholders = List.filled(row.length, '?').join(',');
          await db.customStatement(
            'INSERT INTO "${entry.key}" ($columns) VALUES ($placeholders)',
            row.values.toList(),
          );
        }
      }
    });
    // Raw SQL does not automatically notify Drift stream queries.
    db.notifyUpdates({
      for (final table in db.allTables) TableUpdate(table.actualTableName),
    });
  }
}
