import 'package:flutter/material.dart';
import 'package:indriver_uber_clone/core/extensions/context_extensions.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({
    required this.child,
    this.borderRadius,
    this.margin,
    this.padding,
    this.cardWidth,
    super.key,
  });

  final Widget child;
  final double? cardWidth;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        // background gradient
        SizedBox.expand(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color.fromARGB(255, 0, 0, 0),
                  Color.fromARGB(255, 34, 33, 33),
                ],
              ),
            ),
          ),
        ),

        // background image overlay
        Positioned.fill(
          child: Opacity(
            opacity: 0.2,
            child: Image.asset('assets/img/city_black.jpg', fit: BoxFit.cover),
          ),
        ),

        // content container centered horizontally; vertical positioning lo controla la pantalla (SingleChildScrollView)
        Center(
          child: Container(
            width: cardWidth ?? screenWidth,
            margin: margin ?? EdgeInsets.zero,
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ],
    );
  }
}
