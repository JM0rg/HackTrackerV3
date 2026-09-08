import 'dart:convert';

/// Explicit destinations separate hit credit from what happened on the bases.
/// Destination: 0 = out, 1–3 = base, 4 = scored. Every active runner is listed.
class RunnerDecision {
  const RunnerDecision({
    required this.playerId,
    required this.destination,
    this.rbi = false,
  });
  final String playerId;
  final int destination;
  final bool rbi;
  Map<String, Object?> toJson() => {
    'playerId': playerId,
    'destination': destination,
    'rbi': rbi,
  };
}

class PlayResolution {
  const PlayResolution({
    required this.runners,
    this.thirdOutNegatesRuns = true,
  });
  final List<RunnerDecision> runners;

  /// False only when the scorer confirms runs preceded a non-force third out.
  final bool thirdOutNegatesRuns;
  String encode() => jsonEncode({
    'version': 1,
    'runners': runners.map((r) => r.toJson()).toList(),
    'thirdOutNegatesRuns': thirdOutNegatesRuns,
  });
  static PlayResolution? decode(String? source) {
    if (source == null) return null;
    final map = jsonDecode(source) as Map<String, dynamic>;
    if (map['version'] != 1) {
      throw const FormatException('Update HackTracker to read this play.');
    }
    return PlayResolution(
      runners: [
        for (final r in map['runners'] as List)
          RunnerDecision(
            playerId: r['playerId'] as String,
            destination: r['destination'] as int,
            rbi: r['rbi'] == true,
          ),
      ],
      thirdOutNegatesRuns: map['thirdOutNegatesRuns'] != false,
    );
  }
}
