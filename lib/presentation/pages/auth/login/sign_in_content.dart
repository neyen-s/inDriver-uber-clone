import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    return Stack(
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
            height: context.height,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40.h),
                  _titleMessage(text: 'Welcome'),
                  _titleMessage(text: 'back...'),

                  _carImage(),
                  _loginText(),
                  SignInForm(
                    emailController: emailController,
                    passwordController: passwordController,
                    formKey: formKey,
                  ),

                  SizedBox(height: context.height * 0.14),
                  DefaultButton(
                    text: 'LOGIN',
                    onPressed: () {
                      /*   if (state.formKey!.currentState!.validate()) {
                        context.read<LoginBloc>().add(FormSubmit());
                      } else {
                        print('El formulario no es valido');
                      } */
                    },
                  ),
                  SizedBox(height: 15.h),
                  const SeparatorOr(),
                  SizedBox(height: 10.h),

                  _dontHaveAnAccountSection(),
                  SizedBox(height: 50.h),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Row _dontHaveAnAccountSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: TextStyle(color: Colors.grey[100], fontSize: 16.sp),
        ),
        const SizedBox(width: 7),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacementNamed(context, SignUpPage.routeName);
          },
          child: const Text(
            'sign up',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
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
