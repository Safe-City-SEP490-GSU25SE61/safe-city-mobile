import 'dart:async';
import 'dart:ui';

class Debouncer {
  final Duration delay;
  VoidCallback? _action;
  Timer? _timer;

  Debouncer({required this.delay});

  void run(VoidCallback action) {
    _timer?.cancel();
    _action = action;
    _timer = Timer(delay, () {
      _action?.call();
    });
  }

  void cancel() {
    _timer?.cancel();
  }
}
