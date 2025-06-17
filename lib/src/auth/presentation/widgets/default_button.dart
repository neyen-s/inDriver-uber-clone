import 'package:flutter/material.dart';
import 'package:indriver_uber_clone/core/extensions/context_extensions.dart';

class DefaultButton extends StatelessWidget {
  const DefaultButton({
    required this.text,
    required this.onPressed,
    this.color = Colors.white,
    this.textColor = Colors.black,
    this.margin = const EdgeInsets.only(bottom: 20, left: 40, right: 40),
    super.key,
  });

  final VoidCallback? onPressed; // <-- importante cambio
  final Widget text;
  final Color color;
  final Color textColor;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      width: context.width,
      margin: margin,
      child: ElevatedButton(
        onPressed: onPressed, // <-- ya no lo envolvemos
        style: ElevatedButton.styleFrom(backgroundColor: color),
        child: text,
      ),
    );
  }
}
