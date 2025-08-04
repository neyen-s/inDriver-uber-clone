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
      child: ElevatedButton(
        onPressed: onPressed,
        child: const Text('Confirm destination'),
      ),
    );
  }
}
