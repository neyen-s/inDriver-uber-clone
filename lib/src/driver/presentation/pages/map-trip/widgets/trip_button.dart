import 'package:flutter/material.dart';

class TripButton extends StatelessWidget {
  const TripButton({
    required this.onPressed,
    required this.child,
    this.danger = false,
    super.key,
  });
  final VoidCallback? onPressed;
  final Widget child;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    if (danger) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: onPressed,
        child: child,
      );
    }
    return ElevatedButton(onPressed: onPressed, child: child);
  }
}
