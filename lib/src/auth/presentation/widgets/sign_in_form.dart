import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:indriver_uber_clone/core/common/widgets/default_text_field.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({
    required this.emailController,
    required this.passwordController,
    required this.formKey,
    super.key,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  bool obcurePassword = true;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h),

            child: DefaultTextField(
              filled: true,
              fillColour: Colors.white,
              controller: widget.emailController,
              hintText: 'Email Address',
              keyboardType: TextInputType.emailAddress,
              focusNode: FocusNode(), //TODO UPDATE THIS
            ),
          ),
          const SizedBox(height: 25),
          Container(
            margin: EdgeInsets.only(left: 20.w, right: 20.w),
            child: DefaultTextField(
              filled: true,
              fillColour: Colors.white,
              controller: widget.passwordController,
              hintText: 'Password',
              obscureText: obcurePassword,
              keyboardType: TextInputType.visiblePassword,
              focusNode: FocusNode(), //TODO UPDATE THIS
              suffixIcon: IconButton(
                icon: Icon(
                  obcurePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    obcurePassword = !obcurePassword;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
