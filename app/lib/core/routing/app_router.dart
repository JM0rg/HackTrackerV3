import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/screens/otp_verify_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/games/presentation/screens/games_list_screen.dart';
import '../../features/groups/presentation/screens/groups_list_screen.dart';
import '../../features/onboarding/presentation/screens/first_team_onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/welcome_screen.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/teams/data/teams_repository.dart';
import '../../features/teams/presentation/screens/team_detail_screen.dart';
import '../../features/teams/presentation/screens/teams_list_screen.dart';
import '../../shell/app_shell.dart';
import 'routes.dart';

final _rootKey = GlobalKey<NavigatorState>();

/// Notifies go_router on any change that affects routing decisions: auth
/// state, the user's profile (display name onboarding), and their teams
/// (first-team onboarding). One listener so a single `refreshListenable`
/// covers them all.
class _RouterRefresh extends ChangeNotifier {
  void _bump() => notifyListeners();
}

final _routerRefreshProvider = Provider<Listenable>((ref) {
  final notifier = _RouterRefresh();
  ref.listen(authChangesProvider, (_, _) => notifier._bump());
  ref.listen(myProfileProvider, (_, _) => notifier._bump());
  ref.listen(teamsStreamProvider, (_, _) => notifier._bump());
  ref.onDispose(notifier.dispose);
  return notifier;
});

/// The app router. A single `redirect` decides where you belong based on
/// auth + onboarding state — no leaking partial UIs at boundaries.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.teams,
    refreshListenable: ref.watch(_routerRefreshProvider),
    redirect: (context, state) {
      final auth = ref.read(authRepositoryProvider);
      final signedIn = auth.hasSession;
      final at = state.matchedLocation;
      final atAuth = at.startsWith(Routes.signIn);
      final atWelcome = at == Routes.welcome;
      final atWelcomeTeam = at == Routes.welcomeTeam;
      final atOnboarding = atWelcome || atWelcomeTeam;

      // Not signed in → only the auth flow is reachable.
      if (!signedIn) return atAuth ? null : Routes.signIn;

      // Signed in: drop them out of the auth flow.
      if (atAuth) return Routes.teams;

      // Signed in: check onboarding state. While provider data is still
      // loading, don't redirect — the destination screen will show its own
      // skeleton, and we re-evaluate as soon as data lands (via refreshListenable).
      final profile = ref.read(myProfileProvider).value;
      if (profile == null) return null;

      if (!profile.hasDisplayName) {
        return atWelcome ? null : Routes.welcome;
      }

      // Display name set: ensure at least one team exists.
      final teams = ref.read(teamsStreamProvider).value;
      if (teams != null && teams.isEmpty) {
        return atWelcomeTeam ? null : Routes.welcomeTeam;
      }

      // Onboarding complete — bounce out of any leftover onboarding route.
      if (atOnboarding) return Routes.teams;
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
      GoRoute(
        path: Routes.welcome,
        builder: (_, _) => const WelcomeScreen(),
        routes: [
          GoRoute(
            path: 'team',
            builder: (_, _) => const FirstTeamOnboardingScreen(),
          ),
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
