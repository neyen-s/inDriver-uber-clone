import 'package:flutter/material.dart';
import 'package:indriver_uber_clone/src/auth/presentation/pages/sign-in/sign_in_page.dart';

class AppNavigatorService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void navigateToLogin() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      SignInPage.routeName,
      (_) => false,
    );
  }
}
