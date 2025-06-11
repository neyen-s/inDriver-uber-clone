import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/common/widgets/default_text_field_outlined.dart';
import 'package:indriver_uber_clone/core/extensions/context_extensions.dart';
import 'package:indriver_uber_clone/presentation/pages/auth/sign-up/sign_up_page.dart';
import 'package:indriver_uber_clone/presentation/pages/auth/widgets/auth_background.dart';
import 'package:indriver_uber_clone/presentation/pages/auth/widgets/default_button.dart';
import 'package:indriver_uber_clone/presentation/pages/auth/widgets/separator_or.dart';
import 'package:indriver_uber_clone/presentation/pages/auth/widgets/sign_in_form.dart';

class SignInContent extends StatefulWidget {
  const SignInContent({super.key});

  @override
  State<SignInContent> createState() => _SignInContentState();
}

class _SignInContentState extends State<SignInContent> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = bottomInset > 0;

    return GestureDetector(
      onTap: () =>
          FocusScope.of(context).unfocus(), // cerrar teclado al tocar fuera
      child: Stack(
        children: [
          _backgroundButtons(context),
          AuthBackground(
            cardHeight: context.height * 0.95,
            cardWidth: context.width,
            margin: EdgeInsets.only(left: 50.w, bottom: 50.w, top: 0.h),
            gradientColors: const [
              Color.fromARGB(255, 14, 29, 106),
              Color.fromARGB(255, 30, 112, 227),
            ],
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 25.w),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: bottomInset),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.h),
                            _titleMessage(text: 'Welcome'),
                            _titleMessage(text: 'back...'),
                            _carImage(),
                            _loginText(),

                            /*  SignInForm(
                              emailController: emailController,
                              passwordController: passwordController,
                              formKey: formKey,
                            ), */
                            SizedBox(height: 12.h),

                            DefaultTextFieldOutlined(
                              controller: TextEditingController(),
                              componentMargin: EdgeInsets.symmetric(
                                horizontal: 12.w,
                              ),

                              hintText: 'Email Address',
                              prefixIcon: Icons.person,
                              filled: true,
                              fillColour: Colors.white,
                            ),
                            SizedBox(height: 12.h),

                            DefaultTextFieldOutlined(
                              controller: TextEditingController(),
                              componentMargin: EdgeInsets.symmetric(
                                horizontal: 12.w,
                              ),

                              hintText: 'Password',
                              prefixIcon: Icons.lock_outline,
                              filled: true,
                              fillColour: Colors.white,
                            ),
                            SizedBox(
                              height: isKeyboardOpen ? 40.h : 10,
                            ), // espacio solo si el teclado está abierto
                            const Spacer(),
                            DefaultButton(
                              text: 'LOGIN',
                              onPressed: () {
                                // lógica de login
                              },
                            ),
                            SizedBox(height: 15.h),
                            const SeparatorOr(),
                            SizedBox(height: 10.h),
                            _dontHaveAnAccountSection(),
                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dontHaveAnAccountSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        children: [
          Text(
            "Don't have an account?",
            style: TextStyle(color: Colors.grey[100], fontSize: 16.sp),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, SignUpPage.routeName);
            },
            child: Text(
              'sign up',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Text _loginText() {
    return Text(
      'Log in',
      style: TextStyle(
        fontSize: 25.sp,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Container _carImage() {
    return Container(
      alignment: Alignment.centerRight,
      child: Image(
        image: const AssetImage('assets/img/car_white.png'),
        width: 150.w,
        height: 150.h,
      ),
    );
  }

  AuthBackground _backgroundButtons(BuildContext context) {
    return AuthBackground(
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
          GestureDetector(
            onTap: () {
              // Navigator.pushReplacementNamed(context, SignInPage.routeName);
            },
            child: RotatedBox(
              quarterTurns: 1,
              child: Text(
                'Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 100.h),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, SignUpPage.routeName);
            },
            child: RotatedBox(
              quarterTurns: 1,
              child: Text(
                'Sign Up',
                style: TextStyle(color: Colors.white, fontSize: 23.sp),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        ],
      ),
    );
  }

  Widget _titleMessage({required String text}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 30.sp,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
