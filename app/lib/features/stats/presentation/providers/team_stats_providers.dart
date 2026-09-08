import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/stats/data/team_stats_repository.dart';

final teamStatRowsProvider =
    StreamProvider.family<
      List<PlateAppearance>,
      ({String teamId, String? competitionId})
    >((ref, scope) {
      return TeamStatsRepository(
        ref.watch(databaseProvider),
      ).watch(scope.teamId, competitionId: scope.competitionId);
    });
