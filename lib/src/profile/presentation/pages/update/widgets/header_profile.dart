import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/extensions/context_extensions.dart';

class HeaderProfile extends StatelessWidget {
  const HeaderProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 40.h),
      height: context.height * 0.4,
      width: context.width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0E1D6A), Color(0xFF1E70E3)],
        ),
      ),
      child: Text(
        'EDIT PROFILE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
