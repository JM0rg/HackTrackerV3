import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:hacktracker/core/domain/models/game_kind.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:uuid/uuid.dart';

class TrackerRepository {
  TrackerRepository(this._db, this._uuid);

  final AppDatabase _db;
  final Uuid _uuid;

  DateTime _now() => DateTime.now().toUtc();

  Future<List<Team>> teams() {
    return (_db.select(_db.teams)..where((t) => t.deletedAt.isNull())).get();
  }

  Stream<List<Team>> watchTeams() {
    return (_db.select(_db.teams)..where((t) => t.deletedAt.isNull())).watch();
  }

  Future<Team> createTeam({required String name, String type = 'mens'}) async {
    final id = _uuid.v4();
    final now = _now();
    await _db.into(_db.teams).insert(
          TeamsCompanion.insert(
            id: id,
            name: name,
            type: Value(type),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return (_db.select(_db.teams)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> updateTeamSettings(String teamId, Map<String, dynamic> settings) async {
    await (_db.update(_db.teams)..where((t) => t.id.equals(teamId))).write(
          TeamsCompanion(
            settings: Value(jsonEncode(settings)),
            updatedAt: Value(_now()),
            syncState: const Value(1),
          ),
        );
  }

  Future<List<Player>> players(String teamId) {
    return (_db.select(_db.players)
          ..where((t) => t.teamId.equals(teamId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.lastName)]))
        .get();
  }

  Stream<List<Player>> watchPlayers(String teamId) {
    return (_db.select(_db.players)
          ..where((t) => t.teamId.equals(teamId) & t.deletedAt.isNull()))
        .watch();
  }

  Future<Player?> player(String id) {
    return (_db.select(_db.players)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsertPlayer({
    String? id,
    required String teamId,
    required String firstName,
    String lastName = '',
    String? jerseyNumber,
    String bats = 'right',
    String throws = 'right',
    String gender = 'undisclosed',
    String? personId,
  }) async {
    final now = _now();
    final rowId = id ?? _uuid.v4();
    await _db.into(_db.players).insertOnConflictUpdate(
          PlayersCompanion.insert(
            id: rowId,
            teamId: Value(teamId),
            personId: personId == null ? const Value.absent() : Value(personId),
            firstName: firstName,
            lastName: Value(lastName),
            jerseyNumber: Value(jerseyNumber),
            bats: Value(bats),
            throws_: Value(throws),
            gender: Value(gender),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<List<Opponent>> opponents(String teamId) {
    return (_db.select(_db.opponents)
          ..where((t) => t.teamId.equals(teamId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Stream<List<Opponent>> watchOpponents(String teamId) {
    return (_db.select(_db.opponents)
          ..where((t) => t.teamId.equals(teamId) & t.deletedAt.isNull()))
        .watch();
  }

  Future<void> upsertOpponent({
    String? id,
    required String teamId,
    required String name,
  }) async {
    final now = _now();
    await _db.into(_db.opponents).insertOnConflictUpdate(
          OpponentsCompanion.insert(
            id: id ?? _uuid.v4(),
            teamId: teamId,
            name: name,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Stream<List<Competition>> watchCompetitions(String teamId) {
    return (_db.select(_db.competitions)
          ..where((t) => t.teamId.equals(teamId) & t.deletedAt.isNull()))
        .watch();
  }

  Future<void> upsertCompetition({
    String? id,
    required String teamId,
    required String type,
    required String name,
    String? leagueName,
    String? location,
  }) async {
    final now = _now();
    await _db.into(_db.competitions).insertOnConflictUpdate(
          CompetitionsCompanion.insert(
            id: id ?? _uuid.v4(),
            teamId: teamId,
            type: type,
            name: name,
            leagueName: Value(leagueName),
            location: Value(location),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Stream<List<Game>> watchGames(String teamId) {
    return (_db.select(_db.games)
          ..where(
            (t) =>
                t.teamId.equals(teamId) &
                t.kind.equals(GameKind.team) &
                t.deletedAt.isNull(),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.startsAt)]))
        .watch();
  }

  Stream<List<Player>> watchPlayersForGame(String gameId) {
    return watchLineup(gameId).asyncMap((slots) async {
      if (slots.isEmpty) return <Player>[];
      return (_db.select(_db.players)
            ..where((t) => t.id.isIn(slots.map((s) => s.playerId))))
          .get();
    });
  }

  Future<Game?> game(String id) {
    return (_db.select(_db.games)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<Game?> watchGame(String id) {
    return (_db.select(_db.games)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  Future<String> createGame({
    required String teamId,
    String? opponentId,
    String? park,
    DateTime? startsAt,
    String homeAway = 'home',
    List<String> competitionIds = const [],
  }) async {
    final now = _now();
    final id = _uuid.v4();
    await _db.into(_db.games).insert(
          GamesCompanion.insert(
            id: id,
            teamId: Value(teamId),
            kind: const Value(GameKind.team),
            opponentId: Value(opponentId),
            park: Value(park),
            startsAt: Value(startsAt),
            homeAway: Value(homeAway),
            createdAt: now,
            updatedAt: now,
          ),
        );
    for (final cid in competitionIds) {
      await _db.into(_db.gameCompetitions).insert(
            GameCompetitionsCompanion.insert(
              id: _uuid.v4(),
              teamId: teamId,
              gameId: id,
              competitionId: cid,
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
    await _seedLineupFromLastGame(teamId: teamId, gameId: id);
    return id;
  }

  Future<void> _seedLineupFromLastGame({
    required String teamId,
    required String gameId,
  }) async {
    final previous = await (_db.select(_db.games)
          ..where((t) => t.teamId.equals(teamId) & t.id.equals(gameId).not() & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
          ..limit(1))
        .get();
    if (previous.isEmpty) return;
    final slots = await (_db.select(_db.lineupSlots)
          ..where((t) => t.gameId.equals(previous.first.id) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.battingOrder)]))
        .get();
    final now = _now();
    for (final slot in slots) {
      await _db.into(_db.lineupSlots).insert(
            LineupSlotsCompanion.insert(
              id: _uuid.v4(),
              teamId: Value(teamId),
              gameId: gameId,
              playerId: slot.playerId,
              battingOrder: slot.battingOrder,
              position: Value(slot.position),
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
  }

  Future<List<LineupSlot>> lineup(String gameId) {
    return (_db.select(_db.lineupSlots)
          ..where((t) => t.gameId.equals(gameId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.battingOrder)]))
        .get();
  }

  Stream<List<LineupSlot>> watchLineup(String gameId) {
    return (_db.select(_db.lineupSlots)
          ..where((t) => t.gameId.equals(gameId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.battingOrder)]))
        .watch();
  }

  Future<void> setLineup({
    required String teamId,
    required String gameId,
    required List<String> playerIds,
  }) async {
    final now = _now();
    await (_db.update(_db.lineupSlots)..where((t) => t.gameId.equals(gameId))).write(
          LineupSlotsCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
            syncState: const Value(1),
          ),
        );
    for (var i = 0; i < playerIds.length; i++) {
      await _db.into(_db.lineupSlots).insert(
            LineupSlotsCompanion.insert(
              id: _uuid.v4(),
              teamId: Value(teamId),
              gameId: gameId,
              playerId: playerIds[i],
              battingOrder: i,
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
  }

  Future<void> claimLocalTeamsAsOwner(String userId) async {
    final teams = await this.teams();
    final now = _now();
    for (final team in teams) {
      final existing = await (_db.select(_db.teamMembers)
            ..where((t) => t.teamId.equals(team.id) & t.userId.equals(userId)))
          .get();
      if (existing.isNotEmpty) continue;
      await _db.into(_db.teamMembers).insert(
            TeamMembersCompanion.insert(
              id: _uuid.v4(),
              teamId: team.id,
              userId: userId,
              role: 'owner',
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
  }

  Future<String> createInvite({required String teamId, required String role}) async {
    final now = _now();
    final code = _uuid.v4().replaceAll('-', '').substring(0, 8).toUpperCase();
    await _db.into(_db.inviteCodes).insert(
          InviteCodesCompanion.insert(
            id: _uuid.v4(),
            teamId: teamId,
            code: code,
            role: role,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return code;
  }

  Future<List<InviteCode>> invites(String teamId) {
    return (_db.select(_db.inviteCodes)
          ..where((t) => t.teamId.equals(teamId) & t.deletedAt.isNull()))
        .get();
  }
}
