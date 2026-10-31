import 'dart:math';

/// Generates short, sortable, collision-resistant ids without extra packages.
abstract final class IdGenerator {
  static final Random _random = Random.secure();
  static const int _randomRange = 1 << 32;

  static String next() {
    final String time = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    final String rand = _random
        .nextInt(_randomRange)
        .toRadixString(36)
        .padLeft(7, '0');
    return '$time$rand';
  }
}
