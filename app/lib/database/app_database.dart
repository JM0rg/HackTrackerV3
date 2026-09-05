import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

const defaultTeamSettings =
    '{"modules":{"spray":false,"fielding":false,"contact":false,"pitching":false},"rules":{"innings":7,"hrLimit":null,"hrLimitExcess":"out","coedMaleWalkTwoBases":false,"courtesyRunner":true,"hideLeaderboard":false}}';

mixin SyncColumns on Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get syncState => integer().withDefault(const Constant(1))();
}

@DataClassName('Person')
class People extends Table with SyncColumns {
  TextColumn get displayName => text().withDefault(const Constant('Me'))();
  TextColumn get firstName => text().withDefault(const Constant('Me'))();
  TextColumn get lastName => text().withDefault(const Constant(''))();
  TextColumn get linkedUserId => text().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// A team you play with in personal games. Metadata only: a name to tag games
/// with, so pickup and league sides can be told apart later. Nothing to do
/// with [Teams], which carry a roster, settings and members.
@DataClassName('PersonalTeam')
class PersonalTeams extends Table with SyncColumns {
  TextColumn get personId => text()();
  TextColumn get name => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Teams extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get type => text().withDefault(const Constant('mens'))();
  TextColumn get settings => text().withDefault(const Constant(defaultTeamSettings))();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class TeamMembers extends Table with SyncColumns {
  TextColumn get teamId => text()();
  TextColumn get userId => text()();
  TextColumn get role => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class InviteCodes extends Table with SyncColumns {
  TextColumn get teamId => text()();
  TextColumn get code => text()();
  TextColumn get role => text()();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Players extends Table with SyncColumns {
  TextColumn get teamId => text().nullable()();
  TextColumn get personId => text().nullable()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text().withDefault(const Constant(''))();
  TextColumn get jerseyNumber => text().nullable()();
  TextColumn get bats => text().withDefault(const Constant('right'))();
  TextColumn get throws_ => text().named('throws').withDefault(const Constant('right'))();
  TextColumn get gender => text().withDefault(const Constant('undisclosed'))();
  TextColumn get status => text().withDefault(const Constant('active'))();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Opponents extends Table with SyncColumns {
  TextColumn get teamId => text()();
  TextColumn get name => text()();
  TextColumn get notes => text().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Competitions extends Table with SyncColumns {
  TextColumn get teamId => text()();
  TextColumn get type => text()();
  TextColumn get name => text()();
  TextColumn get leagueName => text().nullable()();
  TextColumn get location => text().nullable()();
  DateTimeColumn get startsOn => dateTime().nullable()();
  DateTimeColumn get endsOn => dateTime().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Games extends Table with SyncColumns {
  TextColumn get teamId => text().nullable()();
  TextColumn get kind => text().withDefault(const Constant('team'))();
  TextColumn get opponentId => text().nullable()();
  TextColumn get opponentName => text().nullable()();
  TextColumn get playedForName => text().nullable()();

  /// Set when the name came from a saved personal team, so games stay grouped
  /// even if that team is later renamed. Null when the name was typed.
  TextColumn get playedForTeamId => text().nullable()();
  TextColumn get park => text().nullable()();
  DateTimeColumn get startsAt => dateTime().nullable()();
  TextColumn get homeAway => text().withDefault(const Constant('home'))();
  TextColumn get status => text().withDefault(const Constant('scheduled'))();
  IntColumn get ourRuns => integer().withDefault(const Constant(0))();
  IntColumn get theirRuns => integer().withDefault(const Constant(0))();
  IntColumn get currentInning => integer().withDefault(const Constant(1))();
  TextColumn get currentHalf => text().withDefault(const Constant('bottom'))();
  IntColumn get outs => integer().withDefault(const Constant(0))();
  TextColumn get scorerUserId => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get firstBaseId => text().nullable()();
  TextColumn get secondBaseId => text().nullable()();
  TextColumn get thirdBaseId => text().nullable()();
  IntColumn get currentBatterIndex => integer().withDefault(const Constant(0))();

  /// Runs tallied in the opponent half that is under way. Committed to a
  /// `game_events` row when the half ends.
  IntColumn get theirHalfRuns => integer().withDefault(const Constant(0))();

  /// Personal games that keep score: teammates' runs in our half under way.
  /// Your own RBI come from your plate appearances.
  IntColumn get ourHalfRuns => integer().withDefault(const Constant(0))();

  /// `bat` (just your at-bats) or `game` (at-bats plus team scores). Team
  /// games are always `game`.
  TextColumn get scope => text().withDefault(const Constant('game'))();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class GameCompetitions extends Table with SyncColumns {
  TextColumn get teamId => text()();
  TextColumn get gameId => text()();
  TextColumn get competitionId => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LineupSlots extends Table with SyncColumns {
  TextColumn get teamId => text().nullable()();
  TextColumn get gameId => text()();
  TextColumn get playerId => text()();
  IntColumn get battingOrder => integer()();
  TextColumn get position => text().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PlateAppearances extends Table with SyncColumns {
  TextColumn get teamId => text().nullable()();
  TextColumn get gameId => text()();
  TextColumn get playerId => text()();
  TextColumn get personId => text().nullable()();
  IntColumn get sequence => integer()();
  IntColumn get inning => integer()();
  TextColumn get inningHalf => text()();
  TextColumn get result => text()();
  IntColumn get rbi => integer().withDefault(const Constant(0))();
  IntColumn get runsScored => integer().withDefault(const Constant(0))();
  IntColumn get outsRecorded => integer().withDefault(const Constant(0))();
  TextColumn get hitLocation => text().nullable()();
  TextColumn get qualityOfContact => text().nullable()();
  TextColumn get fielderPlayerId => text().nullable()();

  /// Scorer's correction to runs on the play (team) or RBI (personal).
  /// Null means the engine's own count stands.
  IntColumn get runsOnPlay => integer().nullable()();

  /// Personal games: the batter came around to score later in the inning.
  BoolColumn get batterScored => boolean().nullable()();

  /// How an out was made: fly, ground or line. Null when nobody said.
  TextColumn get outKind => text().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Log entries that are not plate appearances. Today: a finished opponent
/// half. Shares one sequence space with `plate_appearances` so the whole game
/// replays and undoes in order.
class GameEvents extends Table with SyncColumns {
  TextColumn get teamId => text().nullable()();
  TextColumn get gameId => text()();
  IntColumn get sequence => integer()();
  TextColumn get kind => text()();
  IntColumn get runs => integer().withDefault(const Constant(0))();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

abstract final class GameEventKind {
  static const theirHalf = 'their_half';

  /// A personal game keeping score ends our half by hand; a team game ends it
  /// on the third out and never writes one of these.
  static const ourHalf = 'our_half';
}

class GameInnings extends Table with SyncColumns {
  TextColumn get teamId => text().nullable()();
  TextColumn get gameId => text()();
  IntColumn get inning => integer()();
  IntColumn get ourRuns => integer().withDefault(const Constant(0))();
  IntColumn get theirRuns => integer().withDefault(const Constant(0))();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalSyncCursors extends Table {
  TextColumn get cursorTable => text()();
  DateTimeColumn get cursor => dateTime()();
  @override
  Set<Column<Object>> get primaryKey => {cursorTable};
}

@DriftDatabase(
  tables: [
    People,
    PersonalTeams,
    Teams,
    TeamMembers,
    InviteCodes,
    Players,
    Opponents,
    Competitions,
    Games,
    GameCompetitions,
    LineupSlots,
    PlateAppearances,
    GameEvents,
    GameInnings,
    LocalSyncCursors,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'hacktracker'));

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) => m.createAll(),
      onUpgrade: (m, from, to) async {
        for (final table in allTables) {
          await m.deleteTable(table.actualTableName);
        }
        await m.createAll();
      },
    );
  }

  SimpleSelectStatement<$TeamsTable, Team> get activeTeams {
    return select(teams)..where((t) => t.deletedAt.isNull());
  }
}
