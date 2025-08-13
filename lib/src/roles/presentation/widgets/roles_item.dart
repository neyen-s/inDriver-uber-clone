import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/domain/entities/user_role_entity.dart';

class RolesItem extends StatefulWidget {
  const RolesItem({required this.role, super.key});

  final UserRoleEntity role;

  @override
  State<RolesItem> createState() => _RolesItemState();
}

class _RolesItemState extends State<RolesItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        debugPrint(' Navigating to ${widget.role.name} page');
        await Navigator.pushReplacementNamed(context, widget.role.route);
      },
      child: Column(
        children: [
          SizedBox(
            height: 100.h,
            child: FadeInImage(
              image: NetworkImage(widget.role.image),
              fit: BoxFit.contain,
              fadeInDuration: const Duration(seconds: 1),
              placeholder: const AssetImage('assets/img/no-image.png'),
            ),
          ),
          SizedBox(height: 10.h),

          Text(
            widget.role.name,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }
}
