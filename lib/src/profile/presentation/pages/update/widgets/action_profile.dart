import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActionProfile extends StatelessWidget {
  const ActionProfile({
    required this.option,
    required this.icon,
    required this.onConfirm,
    super.key,
  });

  final String option;
  final IconData icon;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      child: ListTile(
        onTap: onConfirm,
        leading: Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0E1D6A), Color(0xFF1E70E3)],
            ),
            borderRadius: BorderRadius.circular(100.r),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          option,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
