import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class IconRowInfo extends StatelessWidget {
  const IconRowInfo({
    required this.icon,
    required this.label,
    required this.firstTittle,
    super.key,
  });

  final IconData icon;
  final String label;
  final String firstTittle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        SizedBox(width: 3.h),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(firstTittle, style: const TextStyle(color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }
}
