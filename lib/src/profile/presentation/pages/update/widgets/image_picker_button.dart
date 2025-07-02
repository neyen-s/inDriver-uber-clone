import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ImagePickerButton extends StatelessWidget {
  const ImagePickerButton({required this.onTap, super.key});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.r),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0E1D6A), Color(0xFF1E70E3)],
          ),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.edit, size: 18, color: Colors.white),
      ),
    );
  }
}
