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
      GoRoute(path: '/more', builder: (c, s) => const MoreScreen()),
      GoRoute(path: '/sign-in', builder: (c, s) => const SignInScreen()),
      GoRoute(path: '/team/edit', builder: (c, s) => const TeamEditScreen()),
      GoRoute(
        path: '/team/settings',
        builder: (c, s) => const TeamSettingsScreen(),
      ),
      GoRoute(path: '/team/stats', builder: (c, s) => const TeamStatsScreen()),
      GoRoute(path: '/players', builder: (c, s) => const PlayersScreen()),
      GoRoute(path: '/opponents', builder: (c, s) => const OpponentsScreen()),
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

/// A hairline, three icons, and a tint. No pill behind the selection.
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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.bg,
        border: Border(
          top: BorderSide(color: colors.text.withValues(alpha: 0.06)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 54,
          child: Row(
            children: [
              for (var i = 0; i < _tabs.length; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: i == index,
                    label: _tabs[i].$3,
                    excludeSemantics: true,
                    child: InkResponse(
                      onTap: () => onSelect(i),
                      radius: 40,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            i == index ? _tabs[i].$1 : _tabs[i].$2,
                            size: 24,
                            color: i == index ? colors.accent : colors.muted,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _tabs[i].$3,
                            style: context.text.labelSmall?.copyWith(
                              fontSize: 10.5,
                              color: i == index ? colors.accent : colors.muted,
                              fontWeight: i == index
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
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
