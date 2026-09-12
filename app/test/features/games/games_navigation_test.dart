import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hacktracker/core/di/providers.dart';
import 'package:hacktracker/core/routing/app_router.dart';
import 'package:hacktracker/core/theme/app_theme.dart';
import 'package:hacktracker/core/theme/theme_controller.dart';
import 'package:hacktracker/database/app_database.dart';
import 'package:hacktracker/features/games/presentation/screens/games_screen.dart';
import 'package:hacktracker/features/more/presentation/screens/more_screen.dart';
import 'package:hacktracker/features/premium/data/plan_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Games is a primary tab and plan preview lives in settings', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = (await tester.runAsync(
      () => SharedPreferences.getInstance(),
    ))!;
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );
    expect(container.read(locationTrackingProvider), isFalse);
    final router = container.read(routerProvider);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(theme: AppTheme.dark(), routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Games').last);
    await tester.pumpAndSettle();
    expect(find.byType(GamesScreen), findsOneWidget);
    expect(
      find.text('Every game, across every team. Start one when you’re ready.'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Account & settings'));
    await tester.pumpAndSettle();
    expect(find.byType(MoreScreen), findsOneWidget);
    await tester.ensureVisible(find.text('Team Plus'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Team Plus'));
    await tester.pumpAndSettle();
    expect(container.read(planPreviewProvider), Plan.teamPlus);
    expect(container.read(locationTrackingProvider), isTrue);
    await container.read(planPreviewProvider.notifier).select(Plan.playerPlus);
    expect(container.read(locationTrackingProvider), isTrue);
    await container.read(planPreviewProvider.notifier).select(Plan.free);
    expect(container.read(locationTrackingProvider), isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
    container.dispose();
    await tester.pumpAndSettle();
  });
}
