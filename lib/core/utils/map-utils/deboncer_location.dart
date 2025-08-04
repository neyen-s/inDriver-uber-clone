import 'dart:async';
import 'dart:ui';

class DebouncerLocation {
  DebouncerLocation(this.duration);

  final Duration duration;
  Timer? _timer;

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
