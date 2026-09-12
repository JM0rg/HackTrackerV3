import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hacktracker/core/domain/models/game_scope.dart';
import 'package:hacktracker/core/theme/app_theme.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/games/presentation/widgets/live_card.dart';
import 'package:hacktracker/features/me/data/me_repository.dart';
import 'package:hacktracker/features/me/services/you_stats.dart';
import 'package:hacktracker/features/teams/data/tracker_repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;
  late MeRepository me;
  late TrackerRepository tracker;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    me = MeRepository(db, const Uuid());
    tracker = TrackerRepository(db, const Uuid());
  });
  tearDown(() => db.close());

  /// A game pinned to a known moment, so "today" and the date are stable.
  Future<Game> pinned(String id, DateTime startsAt) async {
    await (db.update(db.games)..where((g) => g.id.equals(id))).write(
      GamesCompanion(startsAt: Value(startsAt)),
    );
    return (await tracker.game(id))!;
  }

  Future<void> show(
    WidgetTester tester,
    Game game, {
    GameLine? line,
    String? teamName,
    required DateTime now,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.dark(),
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: LiveCard(game: game, line: line, teamName: teamName, now: now),
        ),
      ),
    ),
  );

  /// What a key says. Times come back with a narrow no-break space before
  /// AM/PM, which keeps the two from wrapping apart; the words are what these
  /// tests are about, so it reads as an ordinary space here.
  String text(WidgetTester tester, String key) {
    final w = tester.widget(find.byKey(Key(key)));
    final raw = w is Text
        ? (w.data ?? w.textSpan!.toPlainText())
        : (w as RichText).text.toPlainText();
    return raw.replaceAll('\u202f', ' ');
  }

  final evening = DateTime(2026, 9, 11, 19, 10);

  testWidgets('a game that knows nothing is still named by when it started', (
    tester,
  ) async {
    final id = await me.createPersonalGame();
    final game = await pinned(id, evening);
    await show(tester, game, now: DateTime(2026, 9, 11, 21));

    // No names, no score, no at-bats: the moment it started is what is left,
    // and it is enough to tell this game from any other.
    expect(text(tester, 'live-title'), 'Friday, Sep 11');
    expect(text(tester, 'live-when'), 'LIVE · 7:10 PM');
    expect(find.textContaining('No at-bats'), findsNothing);
    expect(find.byKey(const Key('live-standing')), findsNothing);
  });

  testWidgets('a game from another day shows the date, not the time', (
    tester,
  ) async {
    final id = await me.createPersonalGame(opponentName: 'Rockets');
    final game = await pinned(id, evening);
    await show(tester, game, now: DateTime(2026, 9, 13, 10));

    expect(text(tester, 'live-when'), 'LIVE · SEP 11');
  });

  testWidgets('the tag and the title never say the same thing', (tester) async {
    final id = await me.createPersonalGame();
    final game = await pinned(id, evening);
    // Another day, and nothing but the day to go on: the day is the title, so
    // the tag gives the time rather than the date a second time.
    await show(tester, game, now: DateTime(2026, 9, 13, 10));

    expect(text(tester, 'live-title'), 'Friday, Sep 11');
    expect(text(tester, 'live-when'), 'LIVE · 7:10 PM');
    expect(text(tester, 'live-when'), isNot(contains('SEP')));
  });

  testWidgets('the matchup is the headline, as much of it as is known', (
    tester,
  ) async {
    final vs = await pinned(
      await me.createPersonalGame(opponentName: 'Rockets'),
      evening,
    );
    await show(tester, vs, now: evening);
    expect(text(tester, 'live-title'), 'vs Rockets');

    final both = await pinned(
      await me.createPersonalGame(
        opponentName: 'Rockets',
        playedForName: 'Tuesday Crew',
      ),
      evening,
    );
    await show(tester, both, now: evening);
    expect(text(tester, 'live-title'), 'Tuesday Crew vs Rockets');

    final ours = await pinned(
      await me.createPersonalGame(playedForName: 'Tuesday Crew'),
      evening,
    );
    await show(tester, ours, now: evening);
    expect(text(tester, 'live-title'), 'Tuesday Crew');
  });

  testWidgets('your line and the score sit under it', (tester) async {
    final id = await me.createPersonalGame(
      opponentName: 'Rockets',
      scope: GameScope.game,
    );
    await (db.update(db.games)..where((g) => g.id.equals(id))).write(
      const GamesCompanion(
        ourRuns: Value(3),
        theirRuns: Value(2),
        currentInning: Value(4),
        currentHalf: Value('top'),
      ),
    );
    final game = await pinned(id, evening);
    await show(
      tester,
      game,
      now: evening,
      line: const GameLine(
        hits: 1,
        atBats: 2,
        rbi: 1,
        runs: 0,
        results: ['1B'],
      ),
    );

    expect(text(tester, 'live-standing'), '1 for 2 · 1 RBI   3–2 · Top 4');
  });

  testWidgets('where it is played sits with when it started', (tester) async {
    final id = await me.createPersonalGame(
      opponentName: 'Rockets',
      park: 'Riverside Park',
      startsAt: evening,
    );
    final game = (await tracker.game(id))!;
    await show(tester, game, now: DateTime(2026, 9, 11, 21));

    expect(text(tester, 'live-when'), 'LIVE · 7:10 PM · RIVERSIDE PARK');
    expect(text(tester, 'live-title'), 'vs Rockets');
    // Said once: not again under the title.
    expect(find.textContaining('Riverside'), findsNothing);
  });

  testWidgets('a team game names the team it is scoring for', (tester) async {
    final team = await tracker.createTeam(name: 'Tuesday Crew');
    final id = await tracker.createGame(
      teamId: team.id,
      homeAway: 'away',
      startsAt: evening.toUtc(),
    );
    await (db.update(db.games)..where((g) => g.id.equals(id))).write(
      const GamesCompanion(opponentName: Value('Reds')),
    );
    final game = (await tracker.game(id))!;
    await show(tester, game, teamName: team.name, now: evening);

    expect(text(tester, 'live-title'), 'Tuesday Crew vs Reds');
  });
}
