import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/theme/app_theme.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/games/presentation/screens/game_hub_screen.dart';
import 'package:hacktracker/features/me/data/me_repository.dart';
import 'package:uuid/uuid.dart';

void main() {
  late AppDatabase db;
  late MeRepository me;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    me = MeRepository(db, const Uuid());
  });

  tearDown(() => db.close());

  Future<void> pump(WidgetTester tester, GoRouter router) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp.router(theme: AppTheme.dark(), routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  }

  GoRouter routerFor(String start) {
    return GoRouter(
      initialLocation: start,
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Scaffold(body: Text('YOU TAB'))),
        GoRoute(
          path: '/games/:id',
          builder: (_, s) => GameHubScreen(gameId: s.pathParameters['id']!),
        ),
      ],
    );
  }

  testWidgets('a game reached by replacing the stack still has a way out',
      (tester) async {
    await me.ensureMe();
    final id = await me.createPersonalGame(opponentName: 'Reds');
    await pump(tester, routerFor('/games/$id'));

    expect(find.text('Personal game'), findsOneWidget);
    expect(find.byKey(const Key('leave-home')), findsOneWidget);

    await tester.tap(find.byKey(const Key('leave-home')));
    await tester.pumpAndSettle();
    expect(find.text('YOU TAB'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('a game pushed onto the stack keeps its normal back button',
      (tester) async {
    await me.ensureMe();
    final id = await me.createPersonalGame(opponentName: 'Reds');
    final router = routerFor('/');
    await pump(tester, router);

    router.push('/games/$id');
    await tester.pumpAndSettle();

    expect(find.text('Personal game'), findsOneWidget);
    expect(find.byKey(const Key('leave-home')), findsNothing);
    expect(find.byType(BackButton), findsOneWidget);
    await finish(tester);
  });
}
