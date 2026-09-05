/// What a plate appearance produced. Slowpitch: no bunts, so no sacrifice hit.
enum PaResult {
  single,
  double,
  triple,
  homer,
  walk,
  strikeout,
  out,
  sacFly,
  fieldersChoice,
  reachOnError;

  /// Order the result pad shows them in: hits, then the common outs, then the rest.
  static const padOrder = <PaResult>[
    PaResult.single,
    PaResult.double,
    PaResult.triple,
    PaResult.homer,
    PaResult.out,
    PaResult.sacFly,
    PaResult.walk,
    PaResult.strikeout,
    PaResult.fieldersChoice,
    PaResult.reachOnError,
  ];

  String get wire {
    return switch (this) {
      PaResult.single => 'single',
      PaResult.double => 'double',
      PaResult.triple => 'triple',
      PaResult.homer => 'homer',
      PaResult.walk => 'walk',
      PaResult.strikeout => 'strikeout',
      PaResult.out => 'out',
      PaResult.sacFly => 'sac_fly',
      PaResult.fieldersChoice => 'fielders_choice',
      PaResult.reachOnError => 'reach_on_error',
    };
  }

  /// Unknown wire values fall back to a plain out rather than throwing, so one
  /// bad row can never break a whole game replay.
  static PaResult fromWire(String value) {
    for (final r in PaResult.values) {
      if (r.wire == value) return r;
    }
    return PaResult.out;
  }

  bool get isHit {
    return this == PaResult.single ||
        this == PaResult.double ||
        this == PaResult.triple ||
        this == PaResult.homer;
  }

  /// Plate appearance that does not count as an official at-bat.
  bool get isNonAtBat => this == PaResult.walk || this == PaResult.sacFly;

  /// The batter is out on this play.
  bool get recordsOut {
    return this == PaResult.out ||
        this == PaResult.strikeout ||
        this == PaResult.sacFly ||
        this == PaResult.fieldersChoice;
  }

  /// The batter ends the play on base.
  bool get reachesBase {
    return isHit ||
        this == PaResult.walk ||
        this == PaResult.fieldersChoice ||
        this == PaResult.reachOnError;
  }

  /// Runs driven in on this play credit the batter. A strikeout (passed ball)
  /// and a reach on error never do.
  bool get earnsRbi {
    return this != PaResult.strikeout && this != PaResult.reachOnError;
  }

  /// How many bases the batter takes on a clean version of this result.
  int get basesTaken {
    return switch (this) {
      PaResult.single || PaResult.reachOnError => 1,
      PaResult.double => 2,
      PaResult.triple => 3,
      PaResult.homer => 4,
      _ => 0,
    };
  }

  PaKind get kind {
    if (isHit) return PaKind.hit;
    if (recordsOut) return PaKind.out;
    return PaKind.reach;
  }

  String get label {
    return switch (this) {
      PaResult.single => '1B',
      PaResult.double => '2B',
      PaResult.triple => '3B',
      PaResult.homer => 'HR',
      PaResult.walk => 'BB',
      PaResult.strikeout => 'K',
      PaResult.out => 'OUT',
      PaResult.sacFly => 'SF',
      PaResult.fieldersChoice => 'FC',
      PaResult.reachOnError => 'ROE',
    };
  }

  String get longLabel {
    return switch (this) {
      PaResult.single => 'Single',
      PaResult.double => 'Double',
      PaResult.triple => 'Triple',
      PaResult.homer => 'Home run',
      PaResult.walk => 'Walk',
      PaResult.strikeout => 'Strikeout',
      PaResult.out => 'Out',
      PaResult.sacFly => 'Sac fly',
      PaResult.fieldersChoice => "Fielder's choice",
      PaResult.reachOnError => 'Reached on error',
    };
  }
}

/// Grouping the result pad and the play tape colour by.
enum PaKind { hit, out, reach }
