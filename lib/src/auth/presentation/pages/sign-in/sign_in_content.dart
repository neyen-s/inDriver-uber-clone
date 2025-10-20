import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/common/widgets/default_button.dart';
import 'package:indriver_uber_clone/core/common/widgets/default_text_field_outlined.dart';
import 'package:indriver_uber_clone/core/common/widgets/sync_controller.dart';

import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-in/bloc/sign_in_bloc.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-up/sign_up_page.dart';
import 'package:indriver_uber_clone/src/auth/presentation/viewmodels/sign_in_view_model.dart';
import 'package:indriver_uber_clone/src/auth/presentation/widgets/auth_background.dart';
import 'package:indriver_uber_clone/src/auth/presentation/widgets/separator_or.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/client-home/client_home_page.dart';
import 'package:lottie/lottie.dart';

class SignInContent extends StatefulWidget {
  const SignInContent({super.key});

  @override
  State<SignInContent> createState() => _SignInContentState();
}

class _SignInContentState extends State<SignInContent> {
  late final _emailController = TextEditingController();
  late final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = SignInViewModel.fromState(context.read<SignInBloc>().state);
      _emailController.text = vm.email.value;
      _passwordController.text = vm.password.value;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AuthBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return BlocConsumer<SignInBloc, SignInState>(
              listener: (context, state) async {
                if (state is SignInSuccess) {
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

                if (_emailController.text != vm.email.value) {
                  syncController(_emailController, vm.email.value);
                }
                if (_passwordController.text != vm.password.value) {
                  syncController(_passwordController, vm.password.value);
                }
              },
              builder: (context, state) {
                final vm = SignInViewModel.fromState(state);

                return Align(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 25.w),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize
                            .min, // evita que ocupe toda la pantalla
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10.h),
                          Center(
                            child: Lottie.asset(
                              'assets/lottie/man_waiting_car.json',
                              fit: BoxFit.cover,
                              height: 120.h,
                            ),
                          ),
                          _loginText(),
                          SizedBox(height: 12.h),
                          DefaultTextFieldOutlined(
                            hintText: 'Email Address',
                            prefixIcon: Icons.person,
                            filled: true,
                            fillColour: Colors.white,
                            controller: _emailController,
                            errorText:
                                vm.emailError ??
                                (vm.email.isNotValid && !vm.email.isPure
                                    ? 'Invalid email'
                                    : null),
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
                                vm.passwordError ??
                                (vm.password.isNotValid && !vm.password.isPure
                                    ? 'Invalid password'
                                    : null),
                            onChanged: (value) => context
                                .read<SignInBloc>()
                                .add(SignInPasswordChanged(value)),
                          ),
                          SizedBox(height: 20.h),
                          if (vm.error != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
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
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                            color: const Color.fromARGB(255, 59, 170, 226),
                            onPressed: vm.isSubmitting
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
    );
  }

  Widget _dontHaveAnAccountSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Center(
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
                  decoration: TextDecoration.underline,
                  decorationColor: const Color.fromARGB(255, 59, 170, 226),
                  decorationStyle: TextDecorationStyle.solid,
                  color: const Color.fromARGB(255, 59, 170, 226),
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ],
        ),
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
}
