import 'package:flutter/material.dart';

class BlinkOnChange extends StatefulWidget {
  const BlinkOnChange({
    required this.child,
    required this.watch,
    this.duration = const Duration(milliseconds: 450),
    super.key,
  });
  final Widget child;
  final Object? watch;
  final Duration duration;

  @override
  State<BlinkOnChange> createState() => _BlinkOnChangeState();
}

class _BlinkOnChangeState extends State<BlinkOnChange>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  Object? _last;

  @override
  void initState() {
    super.initState();
    _last = widget.watch;
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didUpdateWidget(covariant BlinkOnChange oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.watch != _last) {
      _last = widget.watch;
      // animate a quick blink
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.25), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.25, end: 1.0), weight: 50),
    ]).animate(_ctrl);
    return FadeTransition(opacity: animation, child: widget.child);
  }
}
