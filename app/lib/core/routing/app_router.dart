import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/screens/otp_verify_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/games/presentation/screens/games_list_screen.dart';
import '../../features/groups/presentation/screens/groups_list_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/teams/presentation/screens/team_detail_screen.dart';
import '../../features/teams/presentation/screens/teams_list_screen.dart';
import '../../shell/app_shell.dart';
import 'go_router_refresh_stream.dart';
import 'routes.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// The app router with a passwordless auth gate. Redirect logic runs on every
/// auth-state change via [GoRouterRefreshStream].
final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authRepositoryProvider);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.teams,
    refreshListenable: GoRouterRefreshStream(auth.authStateChanges),
    redirect: (context, state) {
      final signedIn = auth.hasSession;
      final atAuth = state.matchedLocation.startsWith(Routes.signIn);
      if (!signedIn) return atAuth ? null : Routes.signIn;
      if (atAuth) return Routes.teams;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.signIn,
        builder: (_, _) => const SignInScreen(),
        routes: [
          GoRoute(path: 'verify', builder: (_, _) => const OtpVerifyScreen()),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.teams,
                builder: (_, _) => const TeamsListScreen(),
                routes: [
                  GoRoute(
                    path: 'teams/:teamId',
                    builder: (_, state) => TeamDetailScreen(
                      teamId: state.pathParameters['teamId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.games,
                builder: (_, _) => const GamesListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.groups,
                builder: (_, _) => const GroupsListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
