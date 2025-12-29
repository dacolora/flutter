import 'dart:math';

/// Generador de IDs sin uuid package.
/// Suficiente para offline MVP.
class Id {
  static final _rng = Random();

  static String newId() {
    final t = DateTime.now().microsecondsSinceEpoch.toString();
    final r = _rng.nextInt(1 << 32).toString();
    return '$t-$r';
  }
}