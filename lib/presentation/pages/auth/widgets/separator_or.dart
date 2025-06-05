import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SeparatorOr extends StatelessWidget {
  const SeparatorOr({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 25.w,
          height: 1.h,
          color: Colors.white,
          margin: EdgeInsets.only(right: 5.w),
        ),
        Text(
          'O',
          style: TextStyle(color: Colors.white, fontSize: 17.sp),
        ),
        Container(
          width: 25.w,
          height: 1.h,
          color: Colors.white,
          margin: EdgeInsets.only(left: 5.w),
        ),
      ],
    );
  }
}
