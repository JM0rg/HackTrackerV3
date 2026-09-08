import 'package:hacktracker/features/stats/presentation/screens/spray_chart_screen.dart';
import 'package:hacktracker/features/competitions/presentation/screens/competition_detail_screen.dart';
import 'package:hacktracker/features/games/presentation/screens/games_screen.dart';
import 'package:flutter/material.dart';
import 'package:hacktracker/core/theme/theme_context_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/features/auth/presentation/account_screens.dart';
import 'package:hacktracker/features/competitions/presentation/screens/competitions_screen.dart';
import 'package:hacktracker/features/games/presentation/screens/box_score_screen.dart';
import 'package:hacktracker/features/games/presentation/screens/game_screen.dart';
import 'package:hacktracker/features/games/presentation/screens/lineup_screen.dart';
import 'package:hacktracker/features/me/presentation/screens/you_screen.dart';
import 'package:hacktracker/features/more/presentation/screens/more_screen.dart';
import 'package:hacktracker/features/opponents/presentation/screens/opponents_screen.dart';
import 'package:hacktracker/features/players/presentation/screens/players_screen.dart';
import 'package:hacktracker/features/stats/presentation/screens/team_stats_screen.dart';
import 'package:hacktracker/features/team/presentation/screens/team_edit_screen.dart';
import 'package:hacktracker/features/team/presentation/screens/team_home_screen.dart';
import 'package:hacktracker/features/team/presentation/screens/team_settings_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/spray',
        builder: (c, s) => SprayChartScreen(
          teamId: s.uri.queryParameters['team'],
          gameId: s.uri.queryParameters['game'],
          competitionId: s.uri.queryParameters['competition'],
        ),
      ),
      GoRoute(path: '/more', builder: (c, s) => const MoreScreen()),
      GoRoute(path: '/sign-in', builder: (c, s) => const SignInScreen()),
      GoRoute(path: '/team/edit', builder: (c, s) => const TeamEditScreen()),
      GoRoute(
        path: '/team/settings',
        builder: (c, s) => const TeamSettingsScreen(),
      ),
      GoRoute(
        path: '/team/stats',
        builder: (c, s) => TeamStatsScreen(
          initialCompetitionId: s.uri.queryParameters['competition'],
        ),
      ),
      GoRoute(path: '/players', builder: (c, s) => const PlayersScreen()),
      GoRoute(path: '/opponents', builder: (c, s) => const OpponentsScreen()),
      GoRoute(
        path: '/competitions/:id',
        builder: (c, s) =>
            CompetitionDetailScreen(competitionId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/competitions',
        builder: (c, s) => const CompetitionsScreen(),
      ),
      // A game is one route: Field Mode while it is going, the wrap once it
      // is final. There is no hub in between.
      GoRoute(
        path: '/games/:id',
        builder: (c, s) => GameScreen(gameId: s.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'lineup',
            builder: (c, s) => LineupScreen(gameId: s.pathParameters['id']!),
          ),
          GoRoute(
            path: 'box',
            builder: (c, s) => BoxScoreScreen(gameId: s.pathParameters['id']!),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellKey,
            routes: [GoRoute(path: '/', builder: (c, s) => const YouScreen())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/team', builder: (c, s) => const TeamHomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/games', builder: (c, s) => const GamesScreen()),
            ],
          ),
        ],
      ),
    ],
  );
});

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _TabBar(
        index: navigationShell.currentIndex,
        onSelect: navigationShell.goBranch,
      ),
    );
  }
}

/// A compact scorebook dock with an animated selected tab.
class _TabBar extends StatelessWidget {
  const _TabBar({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  static const _tabs = [
    (Icons.person, Icons.person_outline, 'You'),
    (Icons.groups, Icons.groups_outlined, 'Teams'),
    (Icons.sports_baseball, Icons.sports_baseball_outlined, 'Games'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
        child: Container(
          height: 64,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: colors.surfaceHigh,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: colors.border.withValues(alpha: .7)),
          ),
          child: Row(
            children: [
              for (var i = 0; i < _tabs.length; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: i == index,
                    label: _tabs[i].$3,
                    excludeSemantics: true,
                    child: InkWell(
                      onTap: () => onSelect(i),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : const Duration(milliseconds: 220),
                        decoration: BoxDecoration(
                          color: i == index
                              ? colors.accent.withValues(alpha: .13)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              i == index ? _tabs[i].$1 : _tabs[i].$2,
                              size: 22,
                              color: i == index ? colors.accent : colors.muted,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _tabs[i].$3,
                              style: context.text.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: i == index
                                    ? colors.accent
                                    : colors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
