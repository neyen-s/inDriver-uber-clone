import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/common/widgets/default_text_field.dart';
import 'package:indriver_uber_clone/core/common/widgets/default_text_field_outlined.dart';
import 'package:indriver_uber_clone/core/extensions/context_extensions.dart';
import 'package:indriver_uber_clone/presentation/pages/auth/sign-in/sign_in_page.dart';
import 'package:indriver_uber_clone/presentation/pages/auth/widgets/auth_background.dart';
import 'package:indriver_uber_clone/presentation/pages/auth/widgets/default_button.dart';
import 'package:indriver_uber_clone/presentation/pages/auth/widgets/separator_or.dart';

class SignUpContent extends StatefulWidget {
  const SignUpContent({super.key});

  @override
  State<SignUpContent> createState() => _SignUpContentState();
}

class _SignUpContentState extends State<SignUpContent> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AuthBackground(
          cardHeight: context.height,
          cardWidth: context.width,
          borderRadius: BorderRadius.zero,
          padding: EdgeInsets.only(left: 12.w),
          gradientColors: const [
            Color.fromARGB(255, 12, 38, 145),
            Color.fromARGB(255, 34, 156, 249),
          ],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _textLoginRotated(context),
              SizedBox(height: 100.h),
              _textRegisterRotated(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            ],
          ),
        ),
        AuthBackground(
          cardHeight: context.height * 0.95,
          cardWidth: context.width,
          gradientColors: const [
            Color.fromARGB(255, 14, 29, 106),
            Color.fromARGB(255, 30, 112, 227),
          ],
          margin: EdgeInsets.only(left: 50.w, bottom: 50.w, top: 0.h),

          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 25.w),

            child: Stack(
              children: [
                _imageBackground(),

                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      _imageBanner(),
                      SizedBox(height: 30.h),
                      DefaultTextFieldOutlined(
                        //  controller: TextEditingController(),
                        componentMargin: EdgeInsets.symmetric(horizontal: 12.w),
                        hintText: 'Name',
                        hintStyle: TextStyle(
                          color: Colors.grey[100],
                          fontSize: 16.sp,
                        ),

                        prefixIcon: Icons.person,
                      ),
                      SizedBox(height: 12.h),
                      DefaultTextFieldOutlined(
                        //   controller: TextEditingController(),
                        componentMargin: EdgeInsets.symmetric(horizontal: 12.w),

                        hintText: 'Last name',
                        hintStyle: TextStyle(
                          color: Colors.grey[100],
                          fontSize: 16.sp,
                        ),

                        prefixIcon: Icons.person_2_outlined,
                      ),
                      SizedBox(height: 12.h),
                      DefaultTextFieldOutlined(
                        //  controller: TextEditingController(),
                        componentMargin: EdgeInsets.symmetric(horizontal: 12.w),

                        hintText: 'Email',
                        hintStyle: TextStyle(
                          color: Colors.grey[100],
                          fontSize: 16.sp,
                        ),

                        prefixIcon: Icons.email_outlined,
                      ),
                      SizedBox(height: 12.h),
                      DefaultTextFieldOutlined(
                        //   controller: TextEditingController(),
                        componentMargin: EdgeInsets.symmetric(horizontal: 12.w),

                        hintText: 'Phone number',
                        hintStyle: TextStyle(
                          color: Colors.grey[100],
                          fontSize: 16.sp,
                        ),

                        prefixIcon: Icons.phone_outlined,
                      ),
                      SizedBox(height: 12.h),
                      DefaultTextFieldOutlined(
                        //   : TextEditingController(),
                        componentMargin: EdgeInsets.symmetric(horizontal: 12.w),

                        hintText: 'Password',
                        hintStyle: TextStyle(
                          color: Colors.grey[100],
                          fontSize: 16.sp,
                        ),

                        prefixIcon: Icons.lock_outline,
                      ),
                      SizedBox(height: 12.h),
                      DefaultTextFieldOutlined(
                        //  controller: TextEditingController(),
                        componentMargin: EdgeInsets.symmetric(horizontal: 12.w),

                        hintText: 'Confirm password',
                        hintStyle: TextStyle(
                          color: Colors.grey[100],
                          fontSize: 16.sp,
                        ),

                        prefixIcon: Icons.lock_outline,
                      ),

                      DefaultButton(
                        margin: EdgeInsets.only(
                          top: 20.h,
                          right: 30.w,
                          left: 30.w,
                        ),
                        text: Text('Create account'),
                        onPressed: () {},
                      ),

                      SizedBox(height: 10.h),
                      const SeparatorOr(),
                      SizedBox(height: 10.h),

                      _alreadyHaveAnAccount(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _textRegisterRotated() {
    return RotatedBox(
      quarterTurns: 1,
      child: Text(
        'Sign up',
        style: TextStyle(
          fontSize: 24.sp,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _textLoginRotated(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, 'login');
      },
      child: RotatedBox(
        quarterTurns: 1,
        child: Text(
          'Login',
          style: TextStyle(fontSize: 23.sp, color: Colors.white),
        ),
      ),
    );
  }

  Widget _imageBanner() {
    return Container(
      margin: EdgeInsets.only(top: 60.h),
      alignment: Alignment.center,
      child: Image.asset('assets/img/trip.png', width: 180, height: 180),
    );
  }

  Widget _alreadyHaveAnAccount() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 4,
      children: [
        Text(
          'Already have an account?',
          style: TextStyle(color: Colors.grey[100], fontSize: 16.sp),
        ),
        const SizedBox(width: 7),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacementNamed(context, SignInPage.routeName);
          },
          child: Text(
            'sign in',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _imageBackground() {
    return Container(
      alignment: Alignment.bottomCenter,
      margin: EdgeInsets.only(bottom: 50.h),
      child: Image.asset(
        'assets/img/destination.png',
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.height * 0.4,
        opacity: const AlwaysStoppedAnimation(0.3),
      ),
    );
  }
}
