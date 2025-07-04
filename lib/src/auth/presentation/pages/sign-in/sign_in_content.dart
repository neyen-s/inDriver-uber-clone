import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/common/widgets/default_text_field_outlined.dart';
import 'package:indriver_uber_clone/core/common/widgets/sync_controller.dart';
import 'package:indriver_uber_clone/core/extensions/context_extensions.dart';
import 'package:indriver_uber_clone/core/utils/core_utils.dart';

import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-in/bloc/sign_in_bloc.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-up/sign_up_page.dart';
import 'package:indriver_uber_clone/src/auth/presentation/viewmodels/sign_in_view_model.dart';
import 'package:indriver_uber_clone/src/auth/presentation/widgets/auth_background.dart';
import 'package:indriver_uber_clone/src/auth/presentation/widgets/default_button.dart';
import 'package:indriver_uber_clone/src/auth/presentation/widgets/separator_or.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/client_home_page.dart';

class SignInContent extends StatefulWidget {
  const SignInContent({super.key});

  @override
  State<SignInContent> createState() => _SignInContentState();
}

class _SignInContentState extends State<SignInContent> {
  late final _emailController = TextEditingController();
  late final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = bottomInset > 0;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
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
                  return BlocConsumer<SignInBloc, SignInState>(
                    listener: (context, state) async {
                      if (state is SignInFailure) {
                        CoreUtils.showSnackBar(context, state.message);
                      } else if (state is SignInSuccess) {
                        final authResponse = state.authResponse;
                        debugPrint('authResponse: $authResponse');

                        context.read<SignInBloc>().add(
                          SaveUserSession(authResponse: authResponse),
                        );

                        // Navegar a otra pantalla si querés
                        await Navigator.pushReplacementNamed(
                          context,
                          ClientHomePage.routeName,
                        );
                        return;
                      }
                      if (!mounted) return;

                      final vm = SignInViewModel.fromState(state);

                      syncController(_emailController, vm.email.value);
                      syncController(_passwordController, vm.password.value);
                    },
                    builder: (context, state) {
                      final vm = SignInViewModel.fromState(state);

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
                                SizedBox(height: 12.h),

                                // TODO: Make the forms react only when the user closes the keyboard or goes to another field
                                DefaultTextFieldOutlined(
                                  hintText: 'Email Address',
                                  prefixIcon: Icons.person,
                                  filled: true,
                                  fillColour: Colors.white,
                                  controller: _emailController,
                                  errorText:
                                      vm.email.isNotValid && !vm.email.isPure
                                      ? 'Invalid email'
                                      : null,
                                  onChanged: (value) => context
                                      .read<SignInBloc>()
                                      .add(SignInEmailChanged(value)),
                                ),
                                SizedBox(height: 12.h),
                                DefaultTextFieldOutlined(
                                  hintText: 'Password',
                                  prefixIcon: Icons.lock_outline,
                                  filled: true,
                                  fillColour: Colors.white,
                                  obscureText: true,
                                  controller: _passwordController,
                                  errorText:
                                      vm.password.isNotValid &&
                                          !vm.password.isPure
                                      ? 'Invalid password'
                                      : null,
                                  onChanged: (value) => context
                                      .read<SignInBloc>()
                                      .add(SignInPasswordChanged(value)),
                                ),
                                SizedBox(height: isKeyboardOpen ? 40.h : 10),
                                const Spacer(),
                                if (vm.error != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      vm.error!,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                DefaultButton(
                                  text: vm.isSubmitting
                                      ? const CircularProgressIndicator(
                                          color: Colors.blueAccent,
                                        )
                                      : const Text(
                                          'LOGIN',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                  onPressed: vm.isSubmitting || !vm.isValid
                                      ? null
                                      : () => context.read<SignInBloc>().add(
                                          const SignInSubmitted(),
                                        ),
                                ),
                                SizedBox(height: 15.h),
                                const SeparatorOr(),
                                SizedBox(height: 10.h),
                                _dontHaveAnAccountSection(context),
                                SizedBox(height: 20.h),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dontHaveAnAccountSection(BuildContext context) {
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
