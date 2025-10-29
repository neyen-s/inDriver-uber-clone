import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class DynamicLottieError extends StatelessWidget {
  const DynamicLottieError({this.errorMewsage, this.textStyle, super.key});

  final String? errorMewsage;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Lottie.asset(
            'assets/lottie/error_404.json', //TODO find a different one
            width: 330.w,
            height: 330.h,
          ),
          SizedBox(height: 12.h),
          Text(
            errorMewsage ?? 'Something went wrong, try again later',
            style: textStyle ?? TextStyle(color: Colors.white, fontSize: 16.sp),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
