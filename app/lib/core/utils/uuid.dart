import 'dart:math';

/// Generates RFC-4122 version-4 UUIDs locally so offline-created rows get
/// stable primary keys that upsert cleanly to Postgres on sync.
abstract final class Uuid {
  static final Random _rng = Random.secure();

  static String v4() {
    final bytes = List<int>.generate(16, (_) => _rng.nextInt(256));
    // Set version (4) and variant (10xx) bits.
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).toList();
    return '${hex.sublist(0, 4).join()}-'
        '${hex.sublist(4, 6).join()}-'
        '${hex.sublist(6, 8).join()}-'
        '${hex.sublist(8, 10).join()}-'
        '${hex.sublist(10, 16).join()}';
  }
}
