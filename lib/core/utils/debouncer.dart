import 'dart:async';

import 'package:flutter/foundation.dart';

/// Delays an action until calls stop for [duration].
final class Debouncer {
  Debouncer(this.duration);

  final Duration duration;
  Timer? _timer;

  bool get isPending => _timer?.isActive ?? false;

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Runs the pending action immediately (if any).
  void flush(VoidCallback action) {
    if (!isPending) return;
    _timer?.cancel();
    action();
  }

  void cancel() => _timer?.cancel();

  void dispose() => _timer?.cancel();
}
