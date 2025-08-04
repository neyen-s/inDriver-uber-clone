import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CenterPinIcon extends StatelessWidget {
  const CenterPinIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/img/location_blue.png',
        width: 40.w,
        height: 40.h,
      ),
    );
  }
}
