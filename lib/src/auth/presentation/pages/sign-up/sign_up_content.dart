import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/common/widgets/default_text_field_outlined.dart';
import 'package:indriver_uber_clone/core/common/widgets/sync_controller.dart';
import 'package:indriver_uber_clone/core/extensions/context_extensions.dart';
import 'package:indriver_uber_clone/core/utils/core_utils.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-in/sign_in_page.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-up/bloc/sign_up_bloc.dart';
import 'package:indriver_uber_clone/src/auth/presentation/viewmodels/sign_up_view_model.dart';
import 'package:indriver_uber_clone/src/auth/presentation/widgets/auth_background.dart';
import 'package:indriver_uber_clone/src/auth/presentation/widgets/default_button.dart';
import 'package:indriver_uber_clone/src/auth/presentation/widgets/separator_or.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/client-home/client_home_page.dart';

class SignUpContent extends StatefulWidget {
  const SignUpContent({super.key});

  @override
  State<SignUpContent> createState() => _SignUpContentState();
}

class _SignUpContentState extends State<SignUpContent> {
  late final _nameController = TextEditingController();
  late final _lastNameController = TextEditingController();
  late final _emailController = TextEditingController();
  late final _phoneController = TextEditingController();
  late final _passwordController = TextEditingController();
  late final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Stack(
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return BlocConsumer<SignUpBloc, SignUpState>(
                    listener: (context, state) async {
                      debugPrint('state: $state');

                      if (state is SignUpFailure) {
                        CoreUtils.showSnackBar(context, state.message);
                      } else if (state is SignUpSuccess) {
                        final authResponse = state.authResponse;
                        debugPrint('authResponse: $authResponse');

                        context.read<SignUpBloc>().add(
                          SaveUserSession(authResponse: authResponse),
                        );

                        // Navegar a otra pantalla si querés
                        await Navigator.pushReplacementNamed(
                          context,
                          ClientHomePage.routeName,
                        );
                      }

                      final vm = SignUpViewModel.fromState(state);

                      syncController(_nameController, vm.name.value);
                      syncController(_lastNameController, vm.lastname.value);
                      syncController(_emailController, vm.email.value);
                      syncController(_phoneController, vm.phone.value);
                      syncController(_passwordController, vm.password.value);
                      syncController(
                        _confirmPasswordController,
                        vm.confirmPassword.value,
                      );
                    },
                    builder: (context, state) {
                      final vm = SignUpViewModel.fromState(state);

                      return Stack(
                        children: [
                          _imageBackground(),
                          SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                _imageBanner(),
                                SizedBox(height: 30.h),
                                DefaultTextFieldOutlined(
                                  controller: _nameController,
                                  hintText: 'Name',
                                  prefixIcon: Icons.person,
                                  filled: true,
                                  fillColour: Colors.white,
                                  errorText:
                                      vm.name.isNotValid && !vm.name.isPure
                                      ? 'Invalid name'
                                      : null,
                                  onChanged: (value) => context
                                      .read<SignUpBloc>()
                                      .add(SignUpNameChanged(value)),
                                ),
                                SizedBox(height: 12.h),
                                DefaultTextFieldOutlined(
                                  controller: _lastNameController,
                                  hintText: 'Last name',
                                  prefixIcon: Icons.person_2_outlined,
                                  filled: true,
                                  fillColour: Colors.white,
                                  errorText:
                                      vm.lastname.isNotValid &&
                                          !vm.lastname.isPure
                                      ? 'Invalid last name'
                                      : null,
                                  onChanged: (value) => context
                                      .read<SignUpBloc>()
                                      .add(SignUpLastNameChanged(value)),
                                ),
                                SizedBox(height: 12.h),
                                DefaultTextFieldOutlined(
                                  controller: _emailController,
                                  hintText: 'Email',
                                  prefixIcon: Icons.email_outlined,
                                  filled: true,
                                  fillColour: Colors.white,
                                  errorText:
                                      vm.email.isNotValid && !vm.email.isPure
                                      ? 'Invalid email'
                                      : null,
                                  onChanged: (value) => context
                                      .read<SignUpBloc>()
                                      .add(SignUpEmailChanged(value)),
                                ),
                                SizedBox(height: 12.h),
                                DefaultTextFieldOutlined(
                                  controller: _phoneController,
                                  hintText: 'Phone number',
                                  prefixIcon: Icons.phone_outlined,
                                  filled: true,
                                  fillColour: Colors.white,
                                  errorText:
                                      vm.phone.isNotValid && !vm.phone.isPure
                                      ? 'Invalid phone number'
                                      : null,
                                  onChanged: (value) => context
                                      .read<SignUpBloc>()
                                      .add(SignUpPhoneChanged(value)),
                                ),
                                SizedBox(height: 12.h),
                                DefaultTextFieldOutlined(
                                  controller: _passwordController,
                                  hintText: 'Password',
                                  prefixIcon: Icons.lock_outline,
                                  filled: true,
                                  fillColour: Colors.white,
                                  obscureText: true,
                                  errorText:
                                      vm.password.isNotValid &&
                                          !vm.password.isPure
                                      ? 'Invalid password'
                                      : null,
                                  onChanged: (value) => context
                                      .read<SignUpBloc>()
                                      .add(SignUpPasswordChanged(value)),
                                ),
                                SizedBox(height: 12.h),
                                DefaultTextFieldOutlined(
                                  controller: _confirmPasswordController,
                                  hintText: 'Confirm password',
                                  prefixIcon: Icons.lock_outline,
                                  filled: true,
                                  fillColour: Colors.white,
                                  obscureText: true,
                                  errorText:
                                      vm.confirmPassword.isNotValid &&
                                          !vm.confirmPassword.isPure
                                      ? 'Passwords do not match'
                                      : null,
                                  onChanged: (value) => context
                                      .read<SignUpBloc>()
                                      .add(SignUpConfirmPasswordChanged(value)),
                                ),

                                DefaultButton(
                                  margin: EdgeInsets.only(
                                    top: 20.h,
                                    right: 30.w,
                                    left: 30.w,
                                  ),
                                  text: vm.isSubmitting
                                      ? const CircularProgressIndicator(
                                          color: Colors.blueAccent,
                                        )
                                      : const Text(
                                          'Create account',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                  onPressed: vm.isSubmitting || !vm.isValid
                                      ? () {}
                                      : () => context.read<SignUpBloc>().add(
                                          const SignUpSubmitted(),
                                        ),
                                ),

                                SizedBox(height: 10.h),
                                const SeparatorOr(),
                                SizedBox(height: 10.h),

                                _alreadyHaveAnAccount(),
                              ],
                            ),
                          ),
                        ],
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
