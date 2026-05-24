// Catches: the current-team selection logic dropping the user's pick when
// the list changes, or failing to auto-fall-through when the picked team
// disappears. Without this, switching teams from the dropdown could
// silently revert mid-session or strand the user on a deleted team.
import 'package:app/features/teams/data/teams_repository.dart';
import 'package:app/features/teams/domain/team.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Team _team(String id, String name) =>
    Team(id: id, name: name, teamType: TeamType.coed);

/// Builds a ProviderContainer whose `teamsStreamProvider` is overridden with
/// a synchronous single-value stream. We immediately subscribe (so Riverpod
/// listens to the stream) and pump the event queue so the AsyncValue lands
/// in `data` before any assertion runs.
Future<ProviderContainer> _containerWithTeams(List<Team> teams) async {
  final container = ProviderContainer(
    overrides: [teamsStreamProvider.overrideWith((ref) => Stream.value(teams))],
  );
  addTearDown(container.dispose);
  // Force a subscription and let microtasks flush so the stream emits.
  container.listen(teamsStreamProvider, (_, _) {});
  await pumpEventQueue();
  return container;
}

void main() {
  test('returns null when the team list is empty', () async {
    final c = await _containerWithTeams(const []);

    expect(c.read(currentTeamIdProvider), isNull);
    expect(c.read(currentTeamProvider), isNull);
  });

  test(
    'returns null even when the user has explicitly picked, if list is empty',
    () async {
      final c = await _containerWithTeams(const []);
      c.read(teamSelectionProvider.notifier).select('ghost');

      expect(c.read(currentTeamIdProvider), isNull);
    },
  );

  test('auto-selects the first team when nothing is picked', () async {
    final c = await _containerWithTeams([
      _team('alpha', 'Alpha'),
      _team('bravo', 'Bravo'),
    ]);

    expect(c.read(currentTeamIdProvider), 'alpha');
    expect(c.read(currentTeamProvider)?.name, 'Alpha');
  });

  test("preserves the user's pick when the team still exists", () async {
    final c = await _containerWithTeams([
      _team('alpha', 'Alpha'),
      _team('bravo', 'Bravo'),
    ]);

    c.read(teamSelectionProvider.notifier).select('bravo');

    expect(c.read(currentTeamIdProvider), 'bravo');
    expect(c.read(currentTeamProvider)?.name, 'Bravo');
  });

  test(
    'falls back to the first team when the picked team is missing',
    () async {
      // Simulates "user had picked bravo, then bravo was deleted" — the
      // selection state lingers but the team list no longer contains it.
      final c = await _containerWithTeams([_team('alpha', 'Alpha')]);
      c.read(teamSelectionProvider.notifier).select('bravo');

      expect(c.read(currentTeamIdProvider), 'alpha');
      expect(c.read(currentTeamProvider)?.name, 'Alpha');
    },
  );
}
