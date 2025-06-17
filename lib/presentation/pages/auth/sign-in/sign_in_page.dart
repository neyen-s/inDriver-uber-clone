import 'package:flutter/material.dart';
import 'package:indriver_uber_clone/presentation/pages/auth/sign-in/sign_in_content.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  static const String routeName = '/sign-in';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SignInContent(),
      backgroundColor: Colors.blueAccent,
    );
  }
}
