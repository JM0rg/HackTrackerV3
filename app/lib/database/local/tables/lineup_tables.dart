import 'package:drift/drift.dart';

import 'sync_columns.dart';

/// A lineup for a game. Modeled as its own table (1:N with games) so future
/// multiple-lineup support needs no migration. [teamId] is denormalized for RLS.
@DataClassName('LineupRow')
class Lineups extends Table with SyncColumns {
  TextColumn get gameId => text()();
  TextColumn get teamId => text()();
  TextColumn get name => text().nullable()();
}

/// One batting slot. Variable count per lineup supports batting the whole
/// roster; [fieldPosition] is a slowpitch position code (P..RF, EH) or null.
@DataClassName('LineupSlotRow')
class LineupSlots extends Table with SyncColumns {
  TextColumn get lineupId => text()();
  TextColumn get teamId => text()();
  TextColumn get playerId => text()();
  IntColumn get battingOrder => integer()();
  TextColumn get fieldPosition => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {lineupId, battingOrder},
  ];
}
