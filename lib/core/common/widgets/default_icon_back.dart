import 'package:flutter/material.dart';

class DefaultIconBack extends StatelessWidget {
  const DefaultIconBack({this.color = Colors.white, this.margin, super.key});

  final Color color;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      margin: margin,
      child: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back_ios, size: 35, color: color),
      ),
    );
  }
}
