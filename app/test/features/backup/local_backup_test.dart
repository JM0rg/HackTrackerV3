import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hacktracker/core/domain/pa_result.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/backup/data/local_backup.dart';
import 'package:hacktracker/features/scoring/data/scoring_repository.dart';
import 'package:hacktracker/features/teams/data/tracker_repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<String> seed() async {
    final repo = TrackerRepository(db, const Uuid());
    final team = await repo.createTeam(name: 'Original team');
    await repo.upsertPlayer(teamId: team.id, firstName: 'Sam');
    final player = (await repo.players(team.id)).single;
    final id = await repo.createGame(teamId: team.id, homeAway: 'away');
    await repo.setLineup(teamId: team.id, gameId: id, playerIds: [player.id]);
    await ScoringRepository(
      db,
      const Uuid(),
    ).recordPa(game: (await repo.game(id))!, result: PaResult.homer);
    return id;
  }

  test(
    'restore to a fresh database preserves game, rules, stats and identities',
    () async {
      final id = await seed();
      final snapshot = await LocalBackup(db).export();
      final other = AppDatabase(NativeDatabase.memory());
      try {
        await LocalBackup(other).restore(snapshot);
        final game = (await other.select(other.games).get()).single;
        expect(game.id, id);
        expect(game.ourRuns, 1);
        expect(game.settingsSnapshot, isNotNull);
        expect(
          (await other.select(other.plateAppearances).get()).single.runsScored,
          1,
        );
        expect(
          (await ScoringRepository(other, const Uuid()).replay(id)).ourRuns,
          1,
        );
      } finally {
        await other.close();
      }
    },
  );

  test(
    'version 7 portable backups restore after the scoring upgrade',
    () async {
      final id = await seed();
      final backup = LocalBackup(db);
      final envelope =
          jsonDecode(await backup.export()) as Map<String, dynamic>;
      final payload =
          jsonDecode(envelope['payload'] as String) as Map<String, dynamic>;
      payload['schema'] = 7;
      for (final row in payload['tables']['games'] as List) {
        (row as Map).remove('scoring_draft');
      }
      for (final row in payload['tables']['plate_appearances'] as List) {
        (row as Map).remove('resolution');
        row.remove('batter_was_male');
      }
      for (final row in payload['tables']['game_events'] as List) {
        (row as Map).remove('payload');
      }
      envelope['payload'] = jsonEncode(payload);
      envelope['sha256'] = sha256
          .convert(utf8.encode(envelope['payload'] as String))
          .toString();
      await backup.restore(jsonEncode(envelope));
      expect((await db.select(db.games).get()).single.id, id);
      expect((await ScoringRepository(db, const Uuid()).replay(id)).ourRuns, 1);
    },
  );

  test('damaged backup is rejected without altering current data', () async {
    await seed();
    final backup = LocalBackup(db);
    final envelope = jsonDecode(await backup.export()) as Map<String, dynamic>;
    envelope['payload'] = '{}';
    await expectLater(
      backup.restore(jsonEncode(envelope)),
      throwsFormatException,
    );
    expect((await db.select(db.teams).get()).single.name, 'Original team');
  });

  test(
    'failed restore insertion rolls back deletion of existing records',
    () async {
      final id = await seed();
      final backup = LocalBackup(db);
      final envelope =
          jsonDecode(await backup.export()) as Map<String, dynamic>;
      final payload =
          jsonDecode(envelope['payload'] as String) as Map<String, dynamic>;
      final teams = payload['tables']['teams'] as List;
      teams.add(teams.first); // valid shape, invalid duplicate primary key
      envelope['payload'] = jsonEncode(payload);
      envelope['sha256'] = sha256
          .convert(utf8.encode(envelope['payload'] as String))
          .toString();
      await expectLater(
        backup.restore(jsonEncode(envelope)),
        throwsA(anything),
      );
      expect((await db.select(db.games).get()).single.id, id);
      expect((await db.select(db.teams).get()).single.name, 'Original team');
    },
  );
}
