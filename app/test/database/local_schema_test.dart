// Catches: the local Drift schema failing to open, and the manager API
// failing to round-trip a row through the actual SQLite engine (sync columns,
// defaults, and the StringListConverter all materialize correctly).
import 'package:app/core/services/sync/sync_state.dart';
import 'package:app/database/app_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('a team round-trips with sync-column defaults applied', () async {
    await db.managers.teams.create(
      (o) => o(
        id: const Value('team-1'),
        name: 'Sandlot Sluggers',
        ownerId: 'user-1',
      ),
    );

    final team = await db.managers.teams
        .filter((f) => f.id('team-1'))
        .getSingle();
    expect(team.name, 'Sandlot Sluggers');
    expect(team.teamType, 'coed'); // column default
    expect(team.syncState, SyncState.synced); // enum default (index 0)
    expect(team.deletedAt, isNull);
    expect(team.createdAt, isNotNull);
  });

  test('player default positions persist through the JSON converter', () async {
    await db.managers.teams.create(
      (o) => o(id: const Value('team-1'), name: 'A', ownerId: 'u'),
    );
    await db.managers.players.create(
      (o) => o(
        id: const Value('player-1'),
        teamId: 'team-1',
        name: 'Casey',
        defaultPositions: const Value(['SS', 'P']),
      ),
    );

    final player = await db.managers.players
        .filter((f) => f.id('player-1'))
        .getSingle();
    expect(player.defaultPositions, ['SS', 'P']);
  });
}
