import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({
    required this.cardHeight,
    required this.cardWidth,
    required this.gradientColors,
    required this.child,
    this.margin,
    this.padding,
    super.key,
  });

  final Widget child;
  final List<Color> gradientColors;
  final double cardHeight;
  final double cardWidth;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: cardHeight,
      width: cardWidth,
      margin: margin ?? EdgeInsetsGeometry.zero,
      padding: padding ?? EdgeInsetsGeometry.zero,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          topLeft: Radius.circular(20.r),
        ),
      ),
      child: child,
    );
  }
}
