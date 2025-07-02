import 'package:flutter/material.dart';
import 'package:indriver_uber_clone/core/common/widgets/default_text_field.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.formKey,
    required this.fullNameController,
    super.key,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController fullNameController;
  final GlobalKey<FormState> formKey;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          DefaultTextField(
            controller: widget.fullNameController,
            hintText: 'Full Name',
            keyboardType: TextInputType.name,
            focusNode: FocusNode(), //TODO UPDATE THIS
          ),
          const SizedBox(height: 25),
          DefaultTextField(
            controller: widget.emailController,
            hintText: 'Email address',
            keyboardType: TextInputType.emailAddress,
            focusNode: FocusNode(), //TODO UPDATE THIS
          ),
          const SizedBox(height: 25),
          DefaultTextField(
            controller: widget.passwordController,
            hintText: 'Password',
            obscureText: obscurePassword,
            keyboardType: TextInputType.visiblePassword,
            focusNode: FocusNode(), //TODO UPDATE THIS

            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },
              icon: Icon(
                obscurePassword ? Icons.remove_red_eye : Icons.visibility_off,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 25),
          DefaultTextField(
            controller: widget.confirmPasswordController,
            hintText: 'Confirm Password',
            obscureText: obscureConfirmPassword,
            keyboardType: TextInputType.visiblePassword,
            filled: true,
            fillColour: Colors.white,
            focusNode: FocusNode(), //TODO UPDATE THIS

            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  obscureConfirmPassword = !obscureConfirmPassword;
                });
              },
              icon: Icon(
                obscurePassword ? Icons.remove_red_eye : Icons.visibility_off,
                color: Colors.grey,
              ),
            ),
            overrideValidator: true,
            validator: (value) {
              if (value != widget.passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
