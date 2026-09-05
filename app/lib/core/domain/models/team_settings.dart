import 'dart:convert';

/// What the app does with a home run past the team's limit.
abstract final class HrLimitExcess {
  static const out = 'out';
  static const single = 'single';
}

/// Rules the scoring engine reads. Parsed from `Team.settings` JSON.
class TeamRules {
  const TeamRules({
    this.innings = 7,
    this.hrLimit,
    this.hrLimitExcess = HrLimitExcess.out,
    this.coedMaleWalkTwoBases = false,
    this.courtesyRunner = true,
    this.hideLeaderboard = false,
  });

  final int innings;

  /// Home runs allowed per team per game. Null means no limit.
  final int? hrLimit;

  /// [HrLimitExcess.out] or [HrLimitExcess.single].
  final String hrLimitExcess;

  /// Coed: a walked male batter is awarded two bases.
  final bool coedMaleWalkTwoBases;
  final bool courtesyRunner;
  final bool hideLeaderboard;

  static const defaults = TeamRules();

  factory TeamRules.fromMap(Map<String, dynamic> map) {
    final limit = map['hrLimit'];
    return TeamRules(
      innings: _int(map['innings']) ?? 7,
      hrLimit: limit == null ? null : _int(limit),
      hrLimitExcess: map['hrLimitExcess'] == HrLimitExcess.single
          ? HrLimitExcess.single
          : HrLimitExcess.out,
      coedMaleWalkTwoBases: map['coedMaleWalkTwoBases'] == true,
      courtesyRunner: map['courtesyRunner'] != false,
      hideLeaderboard: map['hideLeaderboard'] == true,
    );
  }

  static int? _int(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

/// Optional detail capture. Off by default; gates the long-press detail sheet.
class TeamModules {
  const TeamModules({
    this.spray = false,
    this.fielding = false,
    this.contact = false,
    this.pitching = false,
  });

  final bool spray;
  final bool fielding;
  final bool contact;
  final bool pitching;

  static const defaults = TeamModules();

  bool get capturesDetail => spray || fielding || contact;

  factory TeamModules.fromMap(Map<String, dynamic> map) {
    return TeamModules(
      spray: map['spray'] == true,
      fielding: map['fielding'] == true,
      contact: map['contact'] == true,
      pitching: map['pitching'] == true,
    );
  }
}

class TeamSettings {
  const TeamSettings({required this.rules, required this.modules});

  final TeamRules rules;
  final TeamModules modules;

  static const defaults = TeamSettings(
    rules: TeamRules.defaults,
    modules: TeamModules.defaults,
  );

  /// Tolerant on purpose: a malformed blob falls back to defaults so scoring
  /// never breaks on bad settings.
  factory TeamSettings.fromJson(String? source) {
    if (source == null || source.trim().isEmpty) return defaults;
    try {
      final decoded = jsonDecode(source);
      if (decoded is! Map<String, dynamic>) return defaults;
      final rules = decoded['rules'];
      final modules = decoded['modules'];
      return TeamSettings(
        rules: rules is Map<String, dynamic>
            ? TeamRules.fromMap(rules)
            : TeamRules.defaults,
        modules: modules is Map<String, dynamic>
            ? TeamModules.fromMap(modules)
            : TeamModules.defaults,
      );
    } on FormatException {
      return defaults;
    }
  }
}
