import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/common/widgets/default_button.dart';
import 'package:lottie/lottie.dart';

class DynamicLottieAndMsg extends StatelessWidget {
  const DynamicLottieAndMsg({
    this.lottiePath,
    this.message,
    this.textStyle,
    this.onPressed,
    this.child,
    super.key,
  });

  final String? lottiePath;
  final String? message;
  final TextStyle? textStyle;
  final VoidCallback? onPressed;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Lottie.asset(
            lottiePath ??
                'assets/lottie/error_404.json', //TODO find a different one
            width: 330.w,
            height: 330.h,
          ),
          SizedBox(height: 12.h),
          Text(
            message ?? 'Something went wrong, try again later',
            style: textStyle ?? TextStyle(color: Colors.white, fontSize: 16.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          if (onPressed != null && child != null)
            DefaultButton(
              onPressed: onPressed,
              text: child!,
              height: 45.h,
              width: 120.w,
              color: Colors.blue.shade400,
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}
