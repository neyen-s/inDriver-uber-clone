import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConfirmRouteBtn extends StatelessWidget {
  const ConfirmRouteBtn({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30.h,
      left: 20.w,
      right: 20.w,
      child: Container(
        height: 35.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(40.r)),
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 19, 58, 213),
              Color.fromARGB(255, 65, 173, 255),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
          ),
          onPressed: onPressed,
          child: Text(
            'Confirm destination',
            style: TextStyle(color: Colors.white, fontSize: 15.sp),
          ),
        ),
      ),
    );
  }
}
