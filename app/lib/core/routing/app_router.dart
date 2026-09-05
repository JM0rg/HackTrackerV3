import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hacktracker/features/auth/presentation/account_screens.dart';
import 'package:hacktracker/features/competitions/presentation/screens/competitions_screen.dart';
import 'package:hacktracker/features/games/presentation/screens/box_score_screen.dart';
import 'package:hacktracker/features/games/presentation/screens/game_hub_screen.dart';
import 'package:hacktracker/features/games/presentation/screens/lineup_screen.dart';
import 'package:hacktracker/features/games/presentation/screens/new_game_screen.dart';
import 'package:hacktracker/features/me/presentation/screens/log_personal_game_screen.dart';
import 'package:hacktracker/features/me/presentation/screens/you_screen.dart';
import 'package:hacktracker/features/more/presentation/screens/more_screen.dart';
import 'package:hacktracker/features/opponents/presentation/screens/opponents_screen.dart';
import 'package:hacktracker/features/players/presentation/screens/players_screen.dart';
import 'package:hacktracker/features/scoring/presentation/screens/field_mode_screen.dart';
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
      GoRoute(path: '/sign-in', builder: (c, s) => const SignInScreen()),
      GoRoute(path: '/team/edit', builder: (c, s) => const TeamEditScreen()),
      GoRoute(path: '/team/settings', builder: (c, s) => const TeamSettingsScreen()),
      GoRoute(path: '/team/stats', builder: (c, s) => const TeamStatsScreen()),
      GoRoute(path: '/players', builder: (c, s) => const PlayersScreen()),
      GoRoute(path: '/opponents', builder: (c, s) => const OpponentsScreen()),
      GoRoute(path: '/competitions', builder: (c, s) => const CompetitionsScreen()),
      GoRoute(path: '/games/new', builder: (c, s) => const NewGameScreen()),
      GoRoute(path: '/games/personal/new', builder: (c, s) => const LogPersonalGameScreen()),
      GoRoute(
        path: '/games/:id',
        builder: (c, s) => GameHubScreen(gameId: s.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'lineup',
            builder: (c, s) => LineupScreen(gameId: s.pathParameters['id']!),
          ),
          GoRoute(
            path: 'play',
            builder: (c, s) => FieldModeScreen(gameId: s.pathParameters['id']!),
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
            routes: [GoRoute(path: '/team', builder: (c, s) => const TeamHomeScreen())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/more', builder: (c, s) => const MoreScreen())],
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: navigationShell.goBranch,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'You'),
          NavigationDestination(icon: Icon(Icons.groups_outlined), label: 'Team'),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }
}
