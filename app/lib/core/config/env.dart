class Env {
  static const supabaseProjectId = 'uzyfohclwmkrqlfnlxxw';

  /// This app must never connect to another product's database.
  static bool isHackTrackerUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.scheme == 'https' &&
        uri.host == '$supabaseProjectId.supabase.co' &&
        uri.userInfo.isEmpty &&
        (!uri.hasPort || uri.port == 443) &&
        (uri.path.isEmpty || uri.path == '/') &&
        !uri.hasQuery &&
        !uri.hasFragment;
  }

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get hasSupabase =>
      isHackTrackerUrl(supabaseUrl) && supabaseAnonKey.isNotEmpty;
}
