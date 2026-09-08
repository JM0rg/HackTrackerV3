import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/teams/data/tracker_repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  test(
    'version 6 upgrade preserves a saved team and freezes its rules',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'hacktracker-upgrade-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/test.sqlite');
      var db = AppDatabase(NativeDatabase(file));
      final repo = TrackerRepository(db, const Uuid());
      final team = await repo.createTeam(name: 'Keep this team');
      await repo.updateTeamSettings(team.id, {
        'rules': {'hrLimit': 2},
      });
      final gameId = await repo.createGame(teamId: team.id);
      await db.customStatement(
        'ALTER TABLE games DROP COLUMN settings_snapshot',
      );
      await db.customStatement(
        'ALTER TABLE plate_appearances DROP COLUMN effective_result',
      );
      for (final column in [
        'games.scoring_draft',
        'plate_appearances.resolution',
        'plate_appearances.batter_was_male',
        'game_events.payload',
      ]) {
        final parts = column.split('.');
        await db.customStatement(
          'ALTER TABLE ${parts[0]} DROP COLUMN ${parts[1]}',
        );
      }
      await db.customStatement('PRAGMA user_version = 6');
      await db.close();
      db = AppDatabase(NativeDatabase(file));
      try {
        final games = await db.select(db.games).get();
        expect(games.single.id, gameId);
        expect(games.single.settingsSnapshot, contains('"hrLimit":2'));
        expect((await db.select(db.teams).get()).single.name, 'Keep this team');
      } finally {
        await db.close();
      }
    },
  );
}
