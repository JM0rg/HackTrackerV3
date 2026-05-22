import 'package:drift/drift.dart';

import '../converters/string_list_converter.dart';
import 'sync_columns.dart';

/// A roster record. Not an app user in the MVP; [linkedUserId] is reserved for
/// the future "player links their account" feature.
@DataClassName('PlayerRow')
class Players extends Table with SyncColumns {
  TextColumn get teamId => text()();
  TextColumn get name => text()();

  /// Text (not int) to preserve "00", "0", and blanks.
  TextColumn get jerseyNumber => text().nullable()();

  /// 'left' | 'right'
  TextColumn get throws => text().nullable()();

  /// 'left' | 'right' | 'switch'
  TextColumn get bats => text().nullable()();

  /// 'male' | 'female' | 'nonbinary' | 'unspecified'
  TextColumn get gender => text().nullable()();

  /// 'full_time' | 'sub' | 'inactive' | 'injured'
  TextColumn get status => text().withDefault(const Constant('full_time'))();

  /// Field-position codes, stored as a JSON array.
  TextColumn get defaultPositions => text()
      .map(const StringListConverter())
      .withDefault(const Constant('[]'))();

  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get linkedUserId => text().nullable()();
}

/// A season or tournament. Games map to groups many-to-many via [GameGroups].
@DataClassName('GroupRow')
class Groups extends Table with SyncColumns {
  TextColumn get teamId => text()();
  TextColumn get name => text()();

  /// 'season' | 'tournament'
  TextColumn get groupType => text()();
  TextColumn get leagueName => text().nullable()();
  TextColumn get location => text().nullable()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
}

/// A scheduled/played game. `result` (W/L/T) mirrors the server's generated
/// column; locally it is recomputed from the scores on write.
@DataClassName('GameRow')
class Games extends Table with SyncColumns {
  TextColumn get teamId => text()();
  TextColumn get opponentName => text().nullable()();
  TextColumn get parkName => text().nullable()();
  TextColumn get cityOrAddress => text().nullable()();
  DateTimeColumn get startTime => dateTime().nullable()();

  /// 'home' | 'away' | 'neutral'
  TextColumn get homeAway => text().withDefault(const Constant('home'))();

  /// 'scheduled' | 'live' | 'final' | 'postponed' | 'cancelled'
  TextColumn get status => text().withDefault(const Constant('scheduled'))();
  IntColumn get ourScore => integer().nullable()();
  IntColumn get oppScore => integer().nullable()();

  /// 'W' | 'L' | 'T' | null
  TextColumn get result => text().nullable()();
  TextColumn get notes => text().nullable()();
}

/// Join row linking a game to a group. Carries [teamId] (denormalized) and full
/// sync columns so link add/remove propagates as a tombstone.
@DataClassName('GameGroupRow')
class GameGroups extends Table with SyncColumns {
  TextColumn get gameId => text()();
  TextColumn get groupId => text()();
  TextColumn get teamId => text()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {gameId, groupId},
  ];
}
