import 'package:flutter/material.dart';
import 'package:indriver_uber_clone/core/extensions/context_extensions.dart';

class DefaultButton extends StatelessWidget {
  const DefaultButton({
    required this.text,
    required this.onPressed,
    this.color = Colors.white,
    this.textColor = Colors.black,
    this.margin = const EdgeInsets.only(bottom: 20, left: 40, right: 40),
    this.width,
    this.height,

    super.key,
  });

  final VoidCallback? onPressed;
  final Widget text;
  final double? height;
  final double? width;
  final Color color;
  final Color textColor;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 45,
      width: width ?? context.width,
      margin: margin,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: color),
        child: text,
      ),
    );
  }
}
