/// Watch companion contract.
///
/// A future SwiftUI (watchOS) or Wear OS shell can emit these events into the
/// phone app. This file is the shared vocabulary only — do not add a
/// `voo_watch` (or other watch SDK) dependency until that shell exists.
library;

class WatchGameState {
  const WatchGameState({
    required this.gameId,
    required this.ourRuns,
    required this.theirRuns,
    required this.inning,
    required this.half,
    required this.outs,
    this.batterName,
    this.firstOccupied = false,
    this.secondOccupied = false,
    this.thirdOccupied = false,
    this.isOurHalf = true,
  });

  final String gameId;
  final int ourRuns;
  final int theirRuns;
  final int inning;
  final String half;
  final int outs;
  final String? batterName;
  final bool firstOccupied;
  final bool secondOccupied;
  final bool thirdOccupied;
  final bool isOurHalf;
}

class WatchAtBatResult {
  const WatchAtBatResult({
    required this.gameId,
    required this.result,
    this.hitLocation,
    this.qualityOfContact,
    this.fielderPlayerId,
  });

  final String gameId;
  final String result;
  final String? hitLocation;
  final String? qualityOfContact;
  final String? fielderPlayerId;
}

class WatchUndo {
  const WatchUndo({required this.gameId});

  final String gameId;
}

class WatchTheirRunsDelta {
  const WatchTheirRunsDelta({required this.gameId, required this.delta});

  final String gameId;
  final int delta;
}
