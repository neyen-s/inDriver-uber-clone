import 'package:flutter/material.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-up/sign_up_content.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  static const String routeName = '/sign-up';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SignUpContent(),
      backgroundColor: Colors.blueAccent,
    );
  }
}
