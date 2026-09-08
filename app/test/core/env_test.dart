import 'package:flutter_test/flutter_test.dart';
import 'package:hacktracker/core/config/env.dart';

void main() {
  test('only the HackTracker HTTPS endpoint is accepted', () {
    expect(
      Env.isHackTrackerUrl('https://uzyfohclwmkrqlfnlxxw.supabase.co'),
      isTrue,
    );
    expect(
      Env.isHackTrackerUrl('https://uzyfohclwmkrqlfnlxxw.supabase.co/'),
      isTrue,
    );
    for (final url in [
      '',
      'https://maxed.supabase.co',
      'http://uzyfohclwmkrqlfnlxxw.supabase.co',
      'https://uzyfohclwmkrqlfnlxxw.supabase.co.attacker.test',
      'https://uzyfohclwmkrqlfnlxxw.supabase.co@attacker.test',
      'https://uzyfohclwmkrqlfnlxxw.supabase.co/path',
    ]) {
      expect(Env.isHackTrackerUrl(url), isFalse, reason: url);
    }
  });
}
