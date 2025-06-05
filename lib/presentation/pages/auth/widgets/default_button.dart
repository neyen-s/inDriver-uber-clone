import 'package:flutter/material.dart';
import 'package:indriver_uber_clone/core/extensions/context_extensions.dart';

class DefaultButton extends StatelessWidget {
  DefaultButton({
    required this.text,
    required this.onPressed,
    this.color = Colors.white,
    this.textColor = Colors.black,
    this.margin = const EdgeInsets.only(bottom: 20, left: 40, right: 40),
    super.key,
  });

  Function() onPressed;
  String text;
  Color color;
  Color textColor;
  EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      width: context.width,
      // alignment: Alignment.center,
      margin: margin,
      child: ElevatedButton(
        onPressed: () {
          onPressed();
        },
        style: ElevatedButton.styleFrom(backgroundColor: color),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
