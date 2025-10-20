import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/common/widgets/default_button.dart';
import 'package:indriver_uber_clone/core/common/widgets/default_text_field_outlined.dart';
import 'package:indriver_uber_clone/core/common/widgets/sync_controller.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-in/sign_in_page.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-up/bloc/sign_up_bloc.dart';
import 'package:indriver_uber_clone/src/auth/presentation/viewmodels/sign_up_view_model.dart';
import 'package:indriver_uber_clone/src/auth/presentation/widgets/auth_background.dart';
import 'package:indriver_uber_clone/src/auth/presentation/widgets/separator_or.dart';
import 'package:indriver_uber_clone/src/client/presentation/pages/client-home/client_home_page.dart';
import 'package:lottie/lottie.dart';

class SignUpContent extends StatefulWidget {
  const SignUpContent({super.key});

  @override
  State<SignUpContent> createState() => _SignUpContentState();
}

class _SignUpContentState extends State<SignUpContent>
    with TickerProviderStateMixin {
  late final _nameController = TextEditingController();
  late final _lastNameController = TextEditingController();
  late final _emailController = TextEditingController();
  late final _phoneController = TextEditingController();
  late final _passwordController = TextEditingController();
  late final _confirmPasswordController = TextEditingController();
  late AnimationController _animatedController;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animatedController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = SignUpViewModel.fromState(context.read<SignUpBloc>().state);
      _nameController.text = vm.name.value;
      _lastNameController.text = vm.lastname.value;
      _emailController.text = vm.email.value;
      _phoneController.text = vm.phone.value;
      _passwordController.text = vm.password.value;
      _confirmPasswordController.text = vm.confirmPassword.value;
    });
  }

  @override
  void dispose() {
    _animatedController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsetsBottom = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AuthBackground(
        child: BlocConsumer<SignUpBloc, SignUpState>(
          listener: (context, state) async {
            if (state is SignUpSuccess) {
              final authResponse = state.authResponse;
              context.read<SignUpBloc>().add(
                SaveUserSession(authResponse: authResponse),
              );
              await Navigator.pushReplacementNamed(
                context,
                ClientHomePage.routeName,
              );
            }

            final vm = SignUpViewModel.fromState(state);
            if (mounted) {
              if (_nameController.text != vm.name.value) {
                syncController(_nameController, vm.name.value);
              }
              if (_lastNameController.text != vm.lastname.value) {
                syncController(_lastNameController, vm.lastname.value);
              }
              if (_emailController.text != vm.email.value) {
                syncController(_emailController, vm.email.value);
              }
              if (_phoneController.text != vm.phone.value) {
                syncController(_phoneController, vm.phone.value);
              }
              if (_passwordController.text != vm.password.value) {
                syncController(_passwordController, vm.password.value);
              }
              if (_confirmPasswordController.text != vm.confirmPassword.value) {
                syncController(
                  _confirmPasswordController,
                  vm.confirmPassword.value,
                );
              }
            }
          },
          builder: (context, state) {
            final vm = SignUpViewModel.fromState(state);

            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  controller: _scrollController,
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: viewInsetsBottom + 12),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 25.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),
                            headerAnimation(),

                            SizedBox(height: 30.h),
                            nameTextfield(vm, context),

                            SizedBox(height: 12.h),
                            lastNameTextfield(vm, context),

                            SizedBox(height: 12.h),
                            emailTextfield(vm, context),

                            SizedBox(height: 12.h),
                            phoneTextfield(vm, context),

                            SizedBox(height: 12.h),
                            passwordTextfield(vm, context),

                            SizedBox(height: 12.h),
                            condirmPasswordTextfield(vm, context),

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
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                              color: const Color.fromARGB(255, 59, 170, 226),
                              onPressed: vm.isSubmitting
                                  ? null
                                  : () => context.read<SignUpBloc>().add(
                                      const SignUpSubmitted(),
                                    ),
                            ),

                            SizedBox(height: 10.h),
                            const SeparatorOr(),
                            SizedBox(height: 10.h),

                            Center(
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 4,
                                children: [
                                  Text(
                                    'Already have an account?',
                                    style: TextStyle(
                                      color: Colors.grey[100],
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pushReplacementNamed(
                                      context,
                                      SignInPage.routeName,
                                    ),
                                    child: Text(
                                      'sign in',
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                          255,
                                          59,
                                          170,
                                          226,
                                        ),
                                        decoration: TextDecoration.underline,
                                        decorationColor: const Color.fromARGB(
                                          255,
                                          59,
                                          170,
                                          226,
                                        ),
                                        decorationStyle:
                                            TextDecorationStyle.solid,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(),
                          ],
                        ),
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

  DefaultTextFieldOutlined condirmPasswordTextfield(
    SignUpViewModel vm,
    BuildContext context,
  ) {
    return DefaultTextFieldOutlined(
      controller: _confirmPasswordController,
      hintText: 'Confirm password',
      prefixIcon: Icons.lock_outline,
      filled: true,
      fillColour: Colors.white,
      obscureText: true,
      errorText: vm.confirmPassword.isNotValid && !vm.confirmPassword.isPure
          ? 'Passwords do not match'
          : null,
      onChanged: (value) =>
          context.read<SignUpBloc>().add(SignUpConfirmPasswordChanged(value)),
    );
  }

  DefaultTextFieldOutlined passwordTextfield(
    SignUpViewModel vm,
    BuildContext context,
  ) {
    return DefaultTextFieldOutlined(
      controller: _passwordController,
      hintText: 'Password',
      prefixIcon: Icons.lock_outline,
      filled: true,
      fillColour: Colors.white,
      obscureText: true,
      errorText: vm.password.isNotValid && !vm.password.isPure
          ? 'Invalid password'
          : null,
      onChanged: (value) =>
          context.read<SignUpBloc>().add(SignUpPasswordChanged(value)),
    );
  }

  DefaultTextFieldOutlined phoneTextfield(
    SignUpViewModel vm,
    BuildContext context,
  ) {
    return DefaultTextFieldOutlined(
      controller: _phoneController,
      hintText: 'Phone number',
      prefixIcon: Icons.phone_outlined,
      filled: true,
      fillColour: Colors.white,
      errorText: vm.phone.isNotValid && !vm.phone.isPure
          ? 'Invalid phone number'
          : null,
      onChanged: (value) =>
          context.read<SignUpBloc>().add(SignUpPhoneChanged(value)),
    );
  }

  DefaultTextFieldOutlined emailTextfield(
    SignUpViewModel vm,
    BuildContext context,
  ) {
    return DefaultTextFieldOutlined(
      controller: _emailController,
      hintText: 'Email',
      prefixIcon: Icons.email_outlined,
      filled: true,
      fillColour: Colors.white,
      errorText: vm.email.isNotValid && !vm.email.isPure
          ? 'Invalid email'
          : null,
      onChanged: (value) =>
          context.read<SignUpBloc>().add(SignUpEmailChanged(value)),
    );
  }

  DefaultTextFieldOutlined lastNameTextfield(
    SignUpViewModel vm,
    BuildContext context,
  ) {
    return DefaultTextFieldOutlined(
      controller: _lastNameController,
      hintText: 'Last name',
      prefixIcon: Icons.person_2_outlined,
      filled: true,
      fillColour: Colors.white,
      errorText: vm.lastname.isNotValid && !vm.lastname.isPure
          ? 'Invalid last name'
          : null,
      onChanged: (value) =>
          context.read<SignUpBloc>().add(SignUpLastNameChanged(value)),
    );
  }

  DefaultTextFieldOutlined nameTextfield(
    SignUpViewModel vm,
    BuildContext context,
  ) {
    return DefaultTextFieldOutlined(
      controller: _nameController,
      hintText: 'Name',
      prefixIcon: Icons.person,
      filled: true,
      fillColour: Colors.white,
      errorText: vm.name.isNotValid && !vm.name.isPure ? 'Invalid name' : null,
      onChanged: (value) =>
          context.read<SignUpBloc>().add(SignUpNameChanged(value)),
    );
  }

  Container headerAnimation() {
    return Container(
      margin: EdgeInsets.only(top: 10.h),
      alignment: Alignment.center,
      child: Lottie.asset(
        controller: _animatedController,

        'assets/lottie/a_driver.json',
        fit: BoxFit.cover,
        height: 110.h,
      ),
    );
  }
}
