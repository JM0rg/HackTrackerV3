import 'package:flutter_riverpod/flutter_riverpod.dart';

/// In-memory "user chose to skip first-team creation" flag. The router gate
/// reads it to suppress the redirect to `/welcome/team` for the rest of the
/// session. Resets on app restart by design — a first-time user who skipped
/// gets one more nudge the next time they open the app, then never again
/// once they have a team.
class FirstTeamSkipController extends Notifier<bool> {
  @override
  bool build() => false;

  void skip() => state = true;
}

final firstTeamSkipProvider = NotifierProvider<FirstTeamSkipController, bool>(
  FirstTeamSkipController.new,
);
