import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/domain/entities/user_entity.dart';
import 'package:indriver_uber_clone/core/extensions/context_extensions.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/profile_update_page.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/widgets/network_avatar.dart';

class ProfileInfoContent extends StatelessWidget {
  const ProfileInfoContent({
    required this.user,
    required this.onProfileUpdated,
    super.key,
  });
  final UserEntity? user;
  final VoidCallback onProfileUpdated;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            headerProfile(context),
            const Spacer(),
            actionProfile(
              option: 'Edit profile',
              icon: Icons.edit,
              ontTap: () => _navigateToUpdateProfile(context),
            ),

            SizedBox(height: 20.h),
          ],
        ),
        _cardUserInfo(context),
      ],
    );
  }

  Future<void> _navigateToUpdateProfile(BuildContext context) async {
    final result = await Navigator.pushNamed(
      context,
      ProfileUpdatePage.routeName,
      arguments: user,
    );

    if (result == true) {
      onProfileUpdated();
    }
  }

  Container _cardUserInfo(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 70.h, left: 20.w, right: 20.w),
      width: context.width,
      // height: 190.h,
      child: Card(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
          child: Column(
            mainAxisSize: MainAxisSize.min, // importante
            children: [
              Container(
                width: math.min(100.w, context.width * 0.25),
                margin: EdgeInsets.only(top: 15.h, bottom: 0.h),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: NetworkAvatar(imageUrl: user?.image, size: 100.w),
                ),
              ),
              SizedBox(height: 8.h),
              // limitar el tamaño de los textos para evitar overflow
              Text(
                '${user?.name} ${user?.lastname}',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                user?.email ?? '',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                user?.phone ?? '',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container headerProfile(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 20.h),
      height: context.height * 0.3,
      width: context.width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0E1D6A), Color(0xFF1E70E3)],
        ),
      ),
      child: Text(
        'User profile',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget actionProfile({
    required String option,
    required IconData icon,
    required VoidCallback ontTap,
  }) {
    return GestureDetector(
      onTap: ontTap,
      child: Container(
        margin: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h),
        child: ListTile(
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
      ),
    );
  }
}
