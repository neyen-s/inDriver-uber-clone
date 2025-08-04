import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/domain/entities/user_entity.dart';
import 'package:indriver_uber_clone/core/extensions/context_extensions.dart';
import 'package:indriver_uber_clone/src/profile/presentation/pages/update/profile_update_page.dart';

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
            actionProfile(
              option: 'Sign out',
              icon: Icons.settings_power,
              ontTap: () {
                print('sign out FUNCTION HERE');
              },
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
      height: 190.h,
      child: Card(
        color: Colors.white,

        surfaceTintColor: Colors.white,
        child: Column(
          children: [
            Container(
              width: 100.w,
              margin: EdgeInsets.only(top: 20.h, bottom: 10.h),
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipOval(
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/img/user.png',
                    image: user?.image ?? '',
                    imageErrorBuilder: (context, error, stackTrace) =>
                        Image.asset('assets/img/user.png'),
                    fit: BoxFit.cover,
                    fadeOutDuration: const Duration(seconds: 1),
                  ),
                ),
              ),
            ),
            Text(
              '${user?.name} ${user?.lastname}',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.email ?? '',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
            ),
            Text(
              user?.phone ?? '',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
            ),
          ],
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
