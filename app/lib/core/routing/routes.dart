/// Canonical route paths and names. Reference these instead of string
/// literals at call sites.
abstract final class Routes {
  static const signIn = '/sign-in';
  static const verify = '/sign-in/verify';

  static const teams = '/';
  static const teamDetail = '/teams/:teamId';
  static const games = '/games';
  static const groups = '/groups';
  static const profile = '/profile';

  static String teamDetailPath(String teamId) => '/teams/$teamId';
}
