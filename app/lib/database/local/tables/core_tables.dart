import 'package:drift/drift.dart';

import 'sync_columns.dart';

/// App-user identity, mirrors a Supabase `profiles` row. `id` equals the auth
/// user id (not a random UUID) — callers set it explicitly.
@DataClassName('ProfileRow')
class Profiles extends Table with SyncColumns {
  TextColumn get displayName => text().nullable()();
  TextColumn get avatarPath => text().nullable()();
}

/// A team the user owns/manages. League and location live on groups/games, not
/// here, because a team plays across many leagues over time.
@DataClassName('TeamRow')
class Teams extends Table with SyncColumns {
  TextColumn get name => text()();

  /// 'mens' | 'womens' | 'coed'
  TextColumn get teamType => text().withDefault(const Constant('coed'))();
  TextColumn get logoPath => text().nullable()();
  TextColumn get primaryColor => text().nullable()();
  TextColumn get secondaryColor => text().nullable()();
  TextColumn get ownerId => text()();
}

/// Membership + role linking a user to a team. MVP only creates owner rows; the
/// role column is here so player/fan joins need no migration later.
@DataClassName('TeamMemberRow')
class TeamMembers extends Table with SyncColumns {
  TextColumn get teamId => text()();
  TextColumn get userId => text()();

  /// 'owner' | 'coach' | 'player' | 'fan'
  TextColumn get role => text().withDefault(const Constant('player'))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {teamId, userId},
  ];
}
