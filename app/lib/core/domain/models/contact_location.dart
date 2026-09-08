import 'dart:convert';
import 'dart:math' as math;

/// A scorer's estimate in fence-radius units, home at (0, 0), CF at (0, 1).
/// Legacy region-only observations deliberately have no point.
class ContactLocation {
  const ContactLocation({this.x, this.y, this.region, this.flight, this.bats});
  final double? x, y;
  final String? region, flight, bats;
  static const regions = [
    'P',
    'C',
    '1B',
    '2B',
    'SS',
    '3B',
    'LF',
    'LCF',
    'CF',
    'RCF',
    'RF',
  ];
  static const flights = ['ground', 'line', 'fly', 'popup'];
  bool get hasPoint => x != null && y != null;
  bool get located => hasPoint || region != null;
  double? get depth => hasPoint ? math.sqrt(x! * x! + y! * y!) : null;
  String? get direction {
    if (!hasPoint) {
      if (['LF', 'LCF', 'SS', '3B'].contains(region)) return 'Left';
      if (['RF', 'RCF', '1B', '2B'].contains(region)) return 'Right';
      return region == null ? null : 'Middle';
    }
    final angle = math.atan2(x!, y!) * 180 / math.pi;
    return angle < -15
        ? 'Left'
        : angle > 15
        ? 'Right'
        : 'Middle';
  }

  String? get sprayRegion {
    if (!hasPoint) return region;
    final angle = math.atan2(x!, y!) * 180 / math.pi;
    if (depth! < .36) {
      return angle < -15
          ? 'SS'
          : angle > 15
          ? '2B'
          : 'P';
    }
    return angle < -27
        ? 'LF'
        : angle < -9
        ? 'LCF'
        : angle < 9
        ? 'CF'
        : angle < 27
        ? 'RCF'
        : 'RF';
  }

  String get label => !located
      ? 'Location unknown'
      : !hasPoint
      ? '$region · area only'
      : '${depth! < .36
            ? 'Infield'
            : depth! < .55
            ? 'Shallow'
            : depth! > .82
            ? 'Deep'
            : 'Outfield'} ${sprayRegion!}';
  ContactLocation withDetails({String? flight, String? bats}) =>
      ContactLocation(
        x: x,
        y: y,
        region: region,
        flight: flight ?? this.flight,
        bats: bats ?? this.bats,
      );
  String encode() => jsonEncode({
    'v': 1,
    if (hasPoint) ...{'x': x, 'y': y},
    if (region != null) 'region': region,
    if (flight != null) 'flight': flight,
    if (bats != null) 'bats': bats,
  });
  static ContactLocation? parse(String? source) {
    if (source == null || source.length > 2048) return null;
    if (regions.contains(source)) return ContactLocation(region: source);
    try {
      final m = jsonDecode(source) as Map<String, dynamic>;
      if (m['v'] != 1) return null;
      for (final key in ['region', 'flight', 'bats']) {
        if (m.containsKey(key) && m[key] == null) return null;
      }
      if (m.containsKey('x') && (m['x'] == null || m['y'] == null)) return null;
      final x = (m['x'] as num?)?.toDouble(), y = (m['y'] as num?)?.toDouble();
      if ((x == null) != (y == null)) return null;
      if (x != null &&
          (!x.isFinite ||
              !y!.isFinite ||
              x.abs() > 1.2 ||
              y < -.15 ||
              y > 1.2 ||
              math.sqrt(x * x + y * y) > 1.25)) {
        return null;
      }
      final region = m['region'] as String?,
          flight = m['flight'] as String?,
          bats = m['bats'] as String?;
      if (region != null && !regions.contains(region) ||
          flight != null && !flights.contains(flight) ||
          bats != null && !['left', 'right'].contains(bats)) {
        return null;
      }
      return ContactLocation(
        x: x,
        y: y,
        region: region,
        flight: flight,
        bats: bats,
      );
    } catch (_) {
      return null;
    }
  }
}
